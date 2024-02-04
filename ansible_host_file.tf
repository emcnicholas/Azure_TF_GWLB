#resource "local_file" "host_file" {
#    content     = <<-EOT
#    ---
#    all:
#      hosts:
#        ftd:
#          ansible_host: ${var.cdFMC}
#          ansible_network_os: cisco.fmcansible.fmc
#          ansible_user: ${var.ftd_user}
#          ansible_password: ${var.ftd_pass}
#          ansible_httpapi_port: 443
#          ansible_httpapi_use_ssl: True
#          ansible_httpapi_validate_certs: False
#          eks_inside_ip: ${data.aws_instance.eks_node_instance.private_ip}
#          eks_outside_ip: ${aws_eip_association.eks_outside_ip_association.private_ip_address}
#    EOT
#    filename = "${path.module}/Ansible/hosts.yaml"
#}

#                ansible_host: {{ fmc_mgmt_ip.public_ip }}
#                ansible_network_os: cisco.fmcansible.fmc
#                ansible_user: admin
#                ansible_password: 123Cisco@123!
#                ansible_httpapi_port: 443
#                ansible_httpapi_use_ssl: True
#                ansible_httpapi_validate_certs: False
#                ftd_mgmt_ip: 172.16.0.10
#                ftd_reg_key: cisco123
#                ftd_nat_id: abc123
#                auth_string: "admin:123Cisco@123!"