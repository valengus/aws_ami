# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'

Vagrant.configure("2") do |config|

  config.vm.define "oracle" do |config|
    config.vm.box              = "generic/oracle8"
    config.vm.hostname         = "oracle"
    config.vm.box_check_update = false
    config.vm.provider :libvirt do |v|
      v.qemu_use_session = false
      v.cpus             = 2
      v.memory           = 4086
    end
    config.vm.provision "ansible" , run: "always" do |ansible|
      ansible.playbook = "ansible/playfiles/cleanup.yml"
    end
  end

end