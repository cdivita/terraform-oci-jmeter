resource "tls_private_key" "controller_key_pair" {
  algorithm = "RSA"
}

resource "tls_private_key" "workers_key_pair" {
  algorithm = "RSA"
}