
# Firewall configuration
firewall --enabled --service=ssh

# Install OS instead of upgrade
install

# Use Oracle Linux yum server repositories as installation source
url --url="https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64"
repo --name="ol8_AppStream" --baseurl="https://yum.oracle.com/repo/OracleLinux/OL8/appstream/x86_64/"


# Root password
rootpw --plaintext root

# Use text install
text
firstboot --disable

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'

# System language
lang en_US.UTF-8

# SELinux configuration
selinux --enforcing

# Installation logging level
logging --level=info

# System timezone
timezone  Europe/Kiev

# Network information
network  --bootproto=dhcp --device=em1 --onboot=yes --hostname=oraclelinux

# System bootloader configuration
bootloader --location=mbr --append="crashkernel=auto"

# Clear the Master Boot Record
zerombr

# Partition information
clearpart --all --initlabel --disklabel=gpt
autopart --type=plain --noboot --nohome --noswap --nolvm --fstype=xfs

services --enabled=NetworkManager,sshd

reboot --eject

%packages
@^minimal-environment
curl
vim
nano
sudo
openssh-server
open-vm-tools
dhclient
net-tools
bind-utils
telnet
iproute
perl
yum-utils
%end