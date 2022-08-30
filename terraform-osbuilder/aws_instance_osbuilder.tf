resource "tls_private_key" "osbuilder_priv_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "osbuilder_priv_key" {
  key_name   = "osbuilder_priv_key"
  public_key = tls_private_key.osbuilder_priv_key.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.osbuilder_priv_key.private_key_pem}' > ssh_key/osbuilder_priv_key ; chmod 600 ssh_key/osbuilder_priv_key"
  }
}

resource "aws_security_group" "osbuilder_security_group" {
  name        = "osbuilder_security_group"
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

resource "aws_instance" "osbuilder" {
  ami                    = data.aws_ami.centos7.id
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.osbuilder_priv_key.id
  vpc_security_group_ids = [aws_security_group.osbuilder_security_group.id]

  root_block_device {
    volume_size = 20
  }

  provisioner "local-exec" {
    environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
    command     = "ansible all -i '${self.public_ip},' -u centos --private-key ssh_key/osbuilder_priv_key -m wait_for_connection"
  }

  # provisioner "local-exec" {
  #   environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
  #   command     = "ansible-playbook -i '${self.public_ip},' -u centos --private-key ssh_key/osbuilder_priv_key ansible/oraclelinux/osbuilder.yml"
  # }

}

resource "null_resource" "seraphim_aws_provisioner" {
  triggers   = { always_run = "${timestamp()}" }

  provisioner "local-exec" {
    environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
    command     = "ansible-playbook -i '${aws_instance.osbuilder.public_ip},' -u centos --private-key ssh_key/osbuilder_priv_key ansible/oraclelinux/osbuilder.yml"
  }
}