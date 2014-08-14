# -*- mode: ruby -*-
# vi: set ft=ruby :

$bootstrap_script = <<__BOOTSTRAP__
echo "Provisioning defaults"

sudo apt-get install -y build-essential git ruby ruby-dev

echo "gem: --no-ri --no-rdoc" > /etc/gemrc

sudo gem install aws-sdk --no-ri --no-rdoc
sudo gem install fpm

echo "Finished provisioning defaults"
__BOOTSTRAP__

Vagrant.configure("2") do |config|
  config.vm.box = "trusty64"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
  config.ssh.forward_agent = true

  config.vm.provider :virtualbox do |vbox|
    vbox.customize ["modifyvm", :id, "--memory", "1024"]
    vbox.customize ["modifyvm", :id, "--cpus", "2"]
  end

  config.vm.provision "shell" do |shell|
    shell.inline = $bootstrap_script
  end

  # @todo - fix to work with Hiera. see datadir: in hiera.yaml
  #config.vm.provision "puppet" do |puppet|
  #  puppet.manifests_path = "puppet/manifests"
  #  puppet.module_path = "puppet/modules"
  #  puppet.manifest_file  = "nodes.pp"
  #end

end
