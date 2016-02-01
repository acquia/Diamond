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

require 'spec_helper'

describe 'acquia_jenkins', :type => :class do
  it { should contain_class('acquia_jenkins') }

  let(:facts) {
    {
      :private_docker_registry => 'registry.example.com/',
      :osfamily => 'RedHat',
      :operatingsystemrelease => '7',
    }
  }

  context 'contains docker puppet module' do
    it {
      should contain_file('/usr/local/bin/update_docker_image.sh')
    }
  end

  context 'contains docker image' do
    let(:param) {
      {
        :version => 'latest',
      }
    }
    it {
      should contain_docker__image('acquia/grid-ci')
        .with_image_tag('latest')
    }
  end

  context 'docker image running' do
    let(:param) {
      {
        :version => 'latest',
      }
    }
    it {
      should contain_docker__run('grid-ci')
        .with_privileged(false)
        .with_image('registry.example.com/acquia/gridci:latest')
    }
  end
end
