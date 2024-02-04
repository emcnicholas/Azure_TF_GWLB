resource "azurerm_network_interface" "web" {
  name                = "web-nic"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name

  ip_configuration {
    name                          = "web-nic-ip"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "web" {
  name                            = "web"
  computer_name                   = "web"
  location                        = azurerm_resource_group.gwlb.location
  resource_group_name             = azurerm_resource_group.gwlb.name
  network_interface_ids           = [azurerm_network_interface.web.id]
  size                            = "Standard_B1s"
  admin_username                  = "azadmin"
  admin_password                  = var.admin_password
  disable_password_authentication = false

  user_data = base64encode(<<-EOT
    #!/bin/bash
    apt update
    apt upgrade
    apt install -y apache2
    echo "<h1> I Love the Flowbee </h1>" >/var/web/html/index.html
  EOT
  )

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy-daily"
    sku       = "22_04-daily-lts"
    version   = "latest"
  }

  os_disk {
    name                 = "web-os-disk"
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