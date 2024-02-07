resource "local_file" "host_file" {
    content     = <<-EOT
    ---
    all:
      hosts:
        cdFMC:
          ansible_host: ${var.cdFMC}
          ansible_network_os: cisco.fmcansible.fmc
          ansible_httpapi_port: 443
          ansible_httpapi_use_ssl: True
          ansible_httpapi_validate_certs: True
          web_lb_public_ip: ${azurerm_public_ip.web_lb.ip_address}
    EOT
    filename = "${path.module}/hosts.yaml"
}