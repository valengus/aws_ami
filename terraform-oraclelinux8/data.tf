data "aws_ami" "oraclelinux8" {
  most_recent = true
  owners      = [var.owners]
  filter {
      name    = "name"
      values  = ["oraclelinux-8-latest_UEK-*"]
  }
  filter {
    name      = "architecture"
    values    = ["x86_64"]
  }
}

variable "region" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "owners" {
  type = string
}