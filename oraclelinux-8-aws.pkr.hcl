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
  headless           = true
  memory             = 2048
  net_device         = "virtio-net"
  qemu_binary        = ""
  vm_name            = "oraclelinux-8-ami.raw"
  boot_wait          = "5s"
  boot_command       = [ "<tab> net.ifnames=0 inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/oraclelinux-8.aws.ks<enter><wait>" ]
}

source "virtualbox-iso" "oraclelinux-8-aws" {
  format               = "ova"
  iso_url              = "https://yum.oracle.com/ISOS/OracleLinux/OL8/u6/x86_64/x86_64-boot-uek.iso"
  iso_checksum         = "sha256:856d4ddfffabb2bed1ffee1e21a82ba81f30156936c908d19b73706f08bfa731"
  boot_command         = [ "<tab> net.ifnames=0 inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/oraclelinux-8.aws.ks<enter><wait>" ]
  boot_wait            = "5s"
  cpus                 = 2
  memory               = 2048
  disk_size            = 4096
  headless             = true
  http_directory       = "http"
  guest_os_type        = "RedHat_64"
  shutdown_command     = "systemctl poweroff"
  ssh_username         = "root"
  ssh_password         = "root"
  ssh_timeout          = "3600s"
  hard_drive_interface = "sata"
  vboxmanage_post = [
    ["modifyvm", "{{.Name}}", "--memory", "1024"],
    ["modifyvm", "{{.Name}}", "--cpus", "1"]
  ]
}

build {
  sources = [
    "sources.qemu.oraclelinux-8-aws",
    "sources.virtualbox-iso.oraclelinux-8-aws"
  ]

  provisioner "ansible" {
    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False",
    ]
    playbook_file     = "ansible/oraclelinux/oraclelinux.yml"
    user              = "${build.User}"
    extra_arguments   = [ "-e", "ansible_ssh_pass=${build.Password}"]
    use_proxy         = false
  }

  provisioner "ansible" {
    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False",
    ]
    playbook_file     = "ansible/oraclelinux/amazon_ssm.yml"
    user              = "${build.User}"
    extra_arguments   = [ "-e", "ansible_ssh_pass=${build.Password}"]
    use_proxy         = false
  }

  provisioner "ansible" {
    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False",
    ]
    playbook_file     = "ansible/oraclelinux/cleanup.yml"
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
    only = [
      "qemu.oraclelinux-8-aws"
    ]
  }

  post-processor "amazon-import" {
    ami_name        = "oraclelinux-8-latest-${local.packerstarttime}"
    format          = "ova"
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
    only = [
      "virtualbox-iso.oraclelinux-8-aws"
    ]
  }

}




source "amazon-ebs" "oraclelinux-8-latest-UEK" {
  region                = var.region
  access_key            = var.access_key
  secret_key            = var.secret_key

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
    playbook_file     = "ansible/oraclelinux/UEK6.yml"
    use_proxy         = false
  }

  provisioner "ansible" {
    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False",
    ]
    playbook_file     = "ansible/oraclelinux/cleanup.yml"
    use_proxy         = false
  }

}