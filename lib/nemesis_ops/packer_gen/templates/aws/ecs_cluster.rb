# Copyright 2015 Acquia, Inc.
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

require_relative 'ubuntu_server'

module NemesisOps::PackerGen::Templates::Aws
  class EcsServer < NemesisOps::PackerGen::Templates::Aws::UbuntuServer
    def initialize(config, server_type = 'm3.medium')
      super(config, server_type)
      setup_docker
    end

    def setup_docker
      script = [
        'curl -sSL https://get.docker.io/gpg | sudo apt-key add -',
        'echo \'deb http://get.docker.io/ubuntu docker main\' | sudo tee -a /etc/apt/sources.list.d/docker.list',
        'sudo apt-get update',
        'sudo apt-get install -y lxc-docker aufs-tools',
        'sudo docker pull amazon/amazon-ecs-agent',
        'sudo rm -f /var/cache/apt/archives/*deb',
      ]
      packer_script = { type: 'shell', inline: script }
      @provisioners.add(packer_script)
    end
  end
end
