data "aws_ami" "oracle86" {
  most_recent = true
  owners      = ["131827586825"]
  filter {
      name    = "name"
      values  = ["OL8.6-x86_64-HVM-*"]
  }
  filter {
    name      = "architecture"
    values    = ["x86_64"]
  }
}

data "aws_ami" "centos7" {
  most_recent = true
  owners      = ["679593333241"]
  filter {
      name    = "name"
      values  = ["CentOS-7-2111*"]
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