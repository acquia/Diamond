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

# Base system bootstrap script
$bootstrap_script = <<__BOOTSTRAP__
echo "Provisioning defaults"

sudo apt-get update -y
sudo apt-get upgrade -y

# Install default packages
sudo apt-get install -y build-essential curl git
sudo apt-get install -y ruby ruby-dev
sudo gem install --no-ri --no-rdoc fpm

# Install latest Docker version
sudo curl -sSL https://get.docker.io/gpg | sudo apt-key add -
sudo echo "deb http://get.docker.io/ubuntu docker main" > /etc/apt/sources.list.d/docker.list
sudo apt-get update -y
sudo apt-get install -y linux-image-extra-`uname -r` aufs-tools
sudo apt-get install -y lxc-docker

echo "Finished provisioning defaults"
__BOOTSTRAP__

# Script to build all packages inside docker containers
$build_scripts = <<__BUILDSCRIPTS__
echo "Building all packages"
sudo -E su -c /vagrant/packages/build_scripts/build-all.sh
echo "Finished building packages"
__BUILDSCRIPTS__

Vagrant.configure("2") do |config|
  config.vm.box = "trusty64"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
  config.ssh.forward_agent = true

  config.vm.provider :virtualbox do |vbox|
    vbox.customize ["modifyvm", :id, "--memory", "1024"]
    vbox.customize ["modifyvm", :id, "--cpus", "2"]
  end

  # Setup the default bootstrap script for our ubuntu base box image
  config.vm.provision "shell", inline: $bootstrap_script

  # Setup the custom docker image from our Dockerfile
  config.vm.provision "docker" do |d|
    d.build_image "/vagrant", args: "-t nemesis"
  end

  # Build all packaging scripts, result will be left in the ./dist directory
  # after vagrant up has been run this can be re-run with: vagrant --provision-with build-scripts
  #config.vm.provision "build-scripts", type: "shell", inline: $build_scripts

end
