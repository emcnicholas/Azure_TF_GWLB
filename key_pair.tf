########################################
# Key Pair
########################################

# Create a UserKeyPair for EC2 instance
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  # rsa_bits  = 4096
  #algorithm = "ED25519"
}

# Save the private key on local file
resource "local_file" "this" {
  content       = tls_private_key.key_pair.private_key_openssh
  filename      = "${var.name}-private-key.pem"
  file_permission = 0600
}