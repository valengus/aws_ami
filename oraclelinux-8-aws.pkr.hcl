variable "s3_bucket_name" {
  type    = string
  default = "${env("TF_VAR_s3_bucket_name")}"
}

variable "region" {
  type    = string
  default = "${env("TF_VAR_region")}"
}

variable "access_key" {
  type    = string
  default = "${env("TF_VAR_access_key")}"
}

variable "secret_key" {
  type    = string
  default = "${env("TF_VAR_secret_key")}"
}

variable "owners" {
  type    = string
  default = "${env("TF_VAR_owners")}"
}

locals {
  packerstarttime = formatdate("YYYYMMDD", timestamp())
}

source "qemu" "oraclelinux-8-aws" {
  iso_url            = "https://yum.oracle.com/ISOS/OracleLinux/OL8/u6/x86_64/x86_64-boot-uek.iso"
  iso_checksum       = "sha256:856d4ddfffabb2bed1ffee1e21a82ba81f30156936c908d19b73706f08bfa731"
  shutdown_command   = "systemctl poweroff"
  accelerator        = "kvm"
  http_directory     = "http"
  ssh_username       = "root"
  ssh_password       = "root"
  ssh_timeout        = "3600s"
  cpus               = 2
  disk_interface     = "virtio-scsi"
  disk_size          = 4096
  disk_cache         = "unsafe"
  disk_discard       = "unmap"
  disk_detect_zeroes = "unmap"
  disk_compression   = true
  format             = "raw"
  headless           = false
  memory             = 2048
  net_device         = "virtio-net"
  qemu_binary        = ""
  vm_name            = "oraclelinux-8-ami"
  boot_wait          = "5s"
  boot_command       = [ "<tab> net.ifnames=0 inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/oraclelinux-8.aws.ks<enter><wait>" ]
}

build {
  sources = [
    "sources.qemu.oraclelinux-8-aws"
  ]

  provisioner "ansible" {
    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False",
    ]
    playbook_file     = "ansible/oraclelinux8/oraclelinux-8.yml"
    user              = "${build.User}"
    extra_arguments   = [ "-e", "ansible_ssh_pass=${build.Password}"]
    use_proxy         = false
  }

  provisioner "ansible" {
    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False",
    ]
    playbook_file     = "ansible/oraclelinux8/amazon_ssm.yml"
    user              = "${build.User}"
    extra_arguments   = [ "-e", "ansible_ssh_pass=${build.Password}"]
    use_proxy         = false
  }

  provisioner "ansible" {
    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False",
    ]
    playbook_file     = "ansible/oraclelinux8/cleanup.yml"
    user              = "${build.User}"
    extra_arguments   = [ "-e", "ansible_ssh_pass=${build.Password}"]
    use_proxy         = false
  }

  post-processor "amazon-import" {
    ami_name        = "oraclelinux-8-latest-${local.packerstarttime}"
    format          = "raw"
    ami_description = "Oraclelinux OS 8 x86_64 image"
    s3_bucket_name  = var.s3_bucket_name
    region          = var.region
    access_key      = var.access_key
    secret_key      = var.secret_key
    license_type    = "BYOL"
    tags = {
      Name = "oraclelinux-8-latest"
    }
    keep_input_artifact = true
  }
}

source "amazon-ebs" "oraclelinux-8-latest-UEK" {
  region          = var.region
  access_key      = var.access_key
  secret_key      = var.secret_key
  source_ami_filter {
    filters = {
      name = "oraclelinux-8-latest-*"
    }
    owners = [var.owners]
    most_recent = true
  }
  tags = {
    Name = "oraclelinux-8-latest_UEK",
  }
  ami_description = "Oraclelinux OS 8 x86_64 image UEK"
  ami_name        = "oraclelinux-8-latest_UEK-${local.packerstarttime}"
  instance_type   =  "t2.micro"
  ssh_username    =  "ec2-user"
}

build {
  sources = [
    "source.amazon-ebs.oraclelinux-8-latest-UEK"
  ]

  provisioner "ansible" {
    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False",
    ]
    playbook_file     = "ansible/oraclelinux8/UEK.yml"
    use_proxy         = false
  }

  provisioner "ansible" {
    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False",
    ]
    playbook_file     = "ansible/oraclelinux8/cleanup.yml"
    use_proxy         = false
  }

}