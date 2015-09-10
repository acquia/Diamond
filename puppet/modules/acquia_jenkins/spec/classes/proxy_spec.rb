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

describe 'acquia_jenkins::proxy', :type => :class do
  let(:facts) {
    {
      :osfamily => 'Debian',
      :lsbdistcodename => 'trusty',
      :lsbdistid => 'ubuntu',
      :jenkins_url => 'jenkins.example.com',
    }
  }

  it { should compile.with_all_deps }

  it { should contain_class('acquia_jenkins::proxy') }

  it { should contain_package('nginx') }

  it { should contain_service('nginx') }

  it { should contain_exec('generate-jenkins-certs') }

  it {
    should contain_file('/etc/nginx/certs')
    should contain_file('/etc/nginx/sites-available/jenkins-proxy')
    should contain_file('/etc/nginx/sites-enabled/default')
    should contain_file('/etc/nginx/sites-enabled/jenkins-proxy')
  }
end
