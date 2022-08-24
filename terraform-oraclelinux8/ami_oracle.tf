resource "aws_key_pair" "ssh_key_ol8" {
  key_name   = "ami_test"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCxztcgfxCw4HHsrUzUc/wqKWsvY01U3FT+MIxlZ7bA5IX4dIbcfU/8i+TvoWbwiN9vJC9BlBlvkyjfKGyMNUxXZTnUpVW2xg1EWXAzEs1RPCsaoUNGt0vTvrzE8UsxDNnQh1jAm3RznUs/jnUqOtF8gv2m0G2kp+b3cynyaTtJohyu+XYqnrdG9BJwqcNGujQRXjhqXe1tj5dKfj53KVxq1HIxZPKPS7K4/TCn4qEyJsBRxJXPfIDdO40EedPUqZ7sVgxy7rn22i6jXpcSb7Voc9m6f0vN16vptD+ImMXERmG3xRrcKTgTmNsuYKrLvpzrU1t0uWVkUUsusffYHigSTz1/wBOz4e/4hRX0t/Jk5edv4UVH7mlxV83AZqkRmrjfbSXOSDUb1TvLW43Jo0hXm6e4HNGJIM1g4a3mDBsgd74JrfbvSNRzsViS5OozG6OkBjnawiNmqEOrp7ZZ/zEL2aVOtkxTv/FlPu/i/RdowoRcJ7KIm5oZ+D9f8QDNTUs="
}

resource "aws_security_group" "ssh_only_ol8" {
  name        = "ami_test_ssh_only"
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
  key_name               = aws_key_pair.ssh_key_ol8.id
  vpc_security_group_ids = [aws_security_group.ssh_only_ol8.id]

  provisioner "local-exec" {
    environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
    command     = "ansible all -i '${self.public_ip},' -u ec2-user --private-key ssh_key/id_rsa -m wait_for_connection"
  }

}