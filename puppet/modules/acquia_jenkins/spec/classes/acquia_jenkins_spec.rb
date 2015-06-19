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

describe 'acquia_jenkins', :type => :module do
  let(:facts) {
    {
      :osfamily => 'Debian',
      :lsbdistcodename => 'trusty',
      :lsbdistid => 'ubuntu'
    }
  }

  it {
    should contain_class('jenkins')
    should contain_class('acquia_jenkins')
    should contain_jenkins__plugin('parameterized-trigger')
    should contain_jenkins__plugin('token-macro')
    should contain_jenkins__plugin('mailer')
    should contain_jenkins__plugin('scm-api')
    should contain_jenkins__plugin('promoted-builds')
    should contain_jenkins__plugin('matrix-project')
    should contain_jenkins__plugin('git-client')
    should contain_jenkins__plugin('ssh-credentials')
    should contain_jenkins__plugin('credentials')
    should contain_jenkins__plugin('git')
    should contain_jenkins__user('darwin')
  }
end
