resource "tls_private_key" "oraclelinux8_priv_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "oraclelinux8_priv_key" {
  key_name   = "oraclelinux8_priv_key"
  public_key = tls_private_key.oraclelinux8_priv_key.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.oraclelinux8_priv_key.private_key_pem}' > ssh_key/oraclelinux8_priv_key ; chmod 400 ssh_key/oraclelinux8_priv_key"
  }
}

resource "aws_security_group" "oraclelinux8_security_group" {
  name        = "oraclelinux8_security_group"
  description = "Allow only SSH inbound traffic"
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ami_oraclelinux8" {
  ami                    = data.aws_ami.oraclelinux8.id
  instance_type          = "t2.small"
  key_name               = aws_key_pair.oraclelinux8_priv_key.id
  vpc_security_group_ids = [aws_security_group.oraclelinux8_security_group.id]

  provisioner "local-exec" {
    environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
    command     = "ansible all -i '${self.public_ip},' -u ec2-user --private-key ssh_key/oraclelinux8_priv_key -m wait_for_connection"
  }

}