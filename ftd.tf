resource "azurerm_public_ip" "ftd-pub-ip" {
  name                = "ftd-pub-ip"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "fw_management" {
  name                = "fw-management-nic"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name

  ip_configuration {
    name                          = "fw-management-nic-ip"
    subnet_id                     = azurerm_subnet.fw_management.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ftd-pub-ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "ftd-ssh" {
  network_interface_id      = azurerm_network_interface.fw_management.id
  network_security_group_id = azurerm_network_security_group.ftd-ssh.id
}

resource "azurerm_network_interface" "fw_diagnostic" {
  name                = "fw-diagnostic-nic"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name

  ip_configuration {
    name                          = "fw-diagnostic-nic-ip"
    subnet_id                     = azurerm_subnet.fw_management.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "fw_data" {
  name                = "fw-data-nic"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name

  ip_configuration {
    name                          = "fw-data-nic-ip"
    subnet_id                     = azurerm_subnet.fw_data.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "fw_ccl" {
  name                = "fw-ccl-nic"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name

  ip_configuration {
    name                          = "fw-cl-nic-ip"
    subnet_id                     = azurerm_subnet.fw_ccl.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create default Access Control Policy
resource "fmc_access_policies" "access_policy" {
  name           = "${var.name}-Access-Policy"
  default_action = "block"
}

resource "sccfm_ftd_device" "ftd" {
  access_policy_name = fmc_access_policies.access_policy.name
  licenses           = ["BASE","MALWARE","URLFilter","THREAT"]
  name               = "ftd-azure"
  virtual            = true
  performance_tier   = "FTDv30"
}

resource "azurerm_linux_virtual_machine" "ftd" {
  name                = "ftd-azure"
  computer_name       = "ftd-azure"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name
  network_interface_ids = [
    azurerm_network_interface.fw_management.id,
    azurerm_network_interface.fw_diagnostic.id,
    azurerm_network_interface.fw_data.id,
    azurerm_network_interface.fw_ccl.id
  ]
  size                            = "Standard_D3_v2"
  admin_username                  = "azadmin"
  admin_password                  = var.admin_password
  disable_password_authentication = false

  custom_data = base64encode(jsonencode(
    {
      "AdminPassword": var.admin_password,
      "Hostname": "ftd-azure",
      "FirewallMode": "Routed",
      "ManageLocally": "No",
      "FmcIp":"${var.cdFMC}",
      "FmcRegKey":"${sccfm_ftd_device.ftd.reg_key}",
      "FmcNatId":"${sccfm_ftd_device.ftd.nat_id}",
      "Cluster": {
        "CclSubnetRange": "${cidrhost(azurerm_subnet.fw_ccl.address_prefixes[0],1)} ${cidrhost(azurerm_subnet.fw_ccl.address_prefixes[0],32)}",
        "ClusterGroupName": "ftd-azure",
        "HealthProbePort": "12345",
        "GatewayLoadBalancerIP": "${azurerm_lb.fw.frontend_ip_configuration[0].private_ip_address}",
        "EncapsulationType": "vxlan",
        "InternalPort": "10800",
        "ExternalPort": "10801",
        "InternalSegId": "800",
        "ExternalSegId": "801"
      }
    }
  )
  )

  source_image_reference {
    publisher = "cisco"
    offer     = "cisco-ftdv"
    sku       = "ftdv-azure-byol"
    version   = "73069.0.0"
  }

  plan {
    publisher = "cisco"
    product = "cisco-ftdv"
    name = "ftdv-azure-byol"
  }

  os_disk {
    name                 = "fw-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username   = "azadmin"
    public_key = tls_private_key.key_pair.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.diag.primary_blob_endpoint
  }
}
#
#resource "cdo_ftd_device_onboarding" "ftd" {
#  depends_on = [azurerm_linux_virtual_machine.ftd]
#  ftd_uid    = cdo_ftd_device.ftd.id
#}