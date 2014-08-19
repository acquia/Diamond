# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Copyright 2014 Acquia, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
