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

module NemesisOps::PackerGen
  module Templates
    module Aws
      module AwsTemplate
        def type
          :aws
        end

        def required_keys
          %w(access_key account_id ami_name instance_type region s3_bucket secret_key source_ami ssh_username x509_key_path x509_cert_path)
        end

        def get_aws_tools
          script = [
            "VERSION=#{NemesisOps::AWS_TOOLS_VERSION}",
            'export DEBIAN_FRONTEND=noninteractive',
            'export UCF_FORCE_CONFFNEW=true',
            '. /etc/lsb-release',
            # Install Puppet
            'wget -q --no-dns-cache --retry-connrefused --waitretry=5 --read-timeout=15 --timeout=15 --tries=10 http://apt.puppetlabs.com/pubkey.gpg -O puppet.gpg',
            'sudo apt-key add puppet.gpg',
            'echo \'deb http://apt.puppetlabs.com ${DISTRIB_CODENAME} main\' | sudo tee -a /etc/apt/sources.list.d/puppet.list',
            'sudo apt-get update',
            'sudo -E apt-get -y install puppet',
            # Configure instance to be an AMI
            'sudo -E apt-get -y -o Dpkg::Options::=\'--force-confdef\' -o Dpkg::Options::=\'--force-confnew\' dist-upgrade',
            'sudo -E apt-get install -y unzip ruby gdisk kpartx mount dmsetup grub',
            'sudo -E apt-get -y install python-setuptools python-pip',
            'sudo apt-get -y autoremove',
            'sudo rm -f /var/cache/apt/archives/*deb',
            'wget -q --no-dns-cache --retry-connrefused --waitretry=5 --read-timeout=15 --timeout=15 --tries=10 http://s3.amazonaws.com/ec2-downloads/ec2-ami-tools-${VERSION}.zip',
            'unzip ec2-ami-tools-${VERSION}.zip',
            'sudo cp -r ec2-ami-tools-${VERSION}/* /usr/local',
            # Fix stupid build by Canonical
            'sudo sed -i \'s/console=hvc0/console=ttyS0 xen_emul_unplug=unnecessary/\' /boot/grub/menu.lst',
            'sudo sed -i \'s/LABEL=UEFI.*//\' /etc/fstab',
            # Cleanup
            'rm -r ~/*',
          ]

          { type: 'shell', inline: script }
        end
      end
    end
  end
end
