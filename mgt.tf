resource "azurerm_public_ip" "mgt" {
  name                = "mgt-ip"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface_security_group_association" "mgt" {
  network_interface_id      = azurerm_network_interface.mgt.id
  network_security_group_id = azurerm_network_security_group.mgt.id
}

resource "azurerm_network_interface" "mgt" {
  name                = "mgt-nic"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name

  ip_configuration {
    name                          = "mgt-nic-ip"
    subnet_id                     = azurerm_subnet.fw_management.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mgt.id
  }
}

resource "azurerm_linux_virtual_machine" "mgt" {
  name                            = "fw-mgt"
  location                        = azurerm_resource_group.gwlb.location
  resource_group_name             = azurerm_resource_group.gwlb.name
  network_interface_ids           = [azurerm_network_interface.mgt.id]
  size                            = "Standard_B1s"
  computer_name                   = "fw-mgt"
  admin_username                  = "azadmin"
  disable_password_authentication = true

  user_data = base64encode(<<-EOT
    #!/bin/bash
    apt update
    apt install -y sshpass
    apt install -y python3-pip
    pip3 install ansible
  EOT
  )

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy-daily"
    sku       = "22_04-daily-lts"
    version   = "latest"
  }

  os_disk {
    name                 = "mgt-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username   = "azadmin"
    public_key = tls_private_key.key_pair.public_key_openssh
  }

  connection {
    type        = "ssh"
    user        = "azadmin"
    host        = azurerm_public_ip.mgt.ip_address
    private_key = file(local_file.this.filename)
    agent       = false
  }

  provisioner "remote-exec" {
    inline = ["sudo cloud-init status --wait"]
  }

  provisioner "file" {
    source      = local_file.this.filename
    destination = "/home/azadmin/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = ["chmod 400 /home/azadmin/.ssh/id_rsa"]
  }
}