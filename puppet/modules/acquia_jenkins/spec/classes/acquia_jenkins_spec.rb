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
  # Mock the environment. :jenkins_plugin_username helps us mock the jenkins
  # user. In production, the root user will su as this user, but for testing
  # we often execute as a non-root user, which fails for any jenkins::plugin
  # definition. The :path variable sets the global execution path for the
  # archive module to exec curl.
  let(:facts) {
    {
      :osfamily => 'Debian',
      :lsbdistcodename => 'trusty',
      :lsbdistid => 'ubuntu',
      :jenkins_email => 'test@host.com',
      :jenkins_plugin_username => `whoami`.chomp!,
      :path => '/bin:/usr/bin:/usr/local/sbin'
    }
  }

  it { should compile.with_all_deps }

  it { should contain_class('acquia_jenkins') }

  it { should contain_group('jenkins') }

  it {
    should contain_user('jenkins').with(
      'groups' => ['jenkins', 'docker'],
    )
  }

  it {
    should contain_file('/mnt/acquia_grid_ci_workspace').with(
      'owner' => 'jenkins',
      'group' => 'jenkins'
    )
  }
  it {
    should contain_file('/mnt/acquia_grid_ci_dist').with(
      'owner' => 'jenkins',
      'group' => 'jenkins'
    )
  }
  it {
    should contain_file('/var/lib/jenkins').with(
      'owner' => 'jenkins',
      'group' => 'jenkins'
    )
  }
  it {
    should contain_file('/var/lib/jenkins/.ssh').with(
      'owner' => 'jenkins',
      'group' => 'jenkins'
    )
  }
  it {
    should contain_file('/var/lib/jenkins/users').with(
      'owner' => 'jenkins',
      'group' => 'jenkins'
    )
  }
  it {
    should contain_file('/var/lib/jenkins/users/admin').with(
      'owner' => 'jenkins',
      'group' => 'jenkins'
    )
  }
  it {
    should contain_file('/var/lib/jenkins/config.xml').with(
      'owner' => 'jenkins',
      'group' => 'jenkins'
    )
  }
  it {
    should contain_file('/var/lib/jenkins/users/admin/config.xml').with(
      'owner' => 'jenkins',
      'group' => 'jenkins'
    )
  }

  it { should contain_exec('create-jenkins-cli-key') }

  it { should contain_class('jenkins::cli_helper') }

  it { should contain_package('bundler') }

  it { should contain_jenkins__plugin('parameterized-trigger') }

  it { should contain_jenkins__plugin('token-macro') }

  it { should contain_jenkins__plugin('mailer') }

  it { should contain_jenkins__plugin('scm-api') }

  it { should contain_jenkins__plugin('promoted-builds') }

  it { should contain_jenkins__plugin('matrix-project') }

  it { should contain_jenkins__plugin('credentials') }

  it { should contain_jenkins__plugin('ssh-credentials') }

  it { should contain_jenkins__plugin('credentials-binding') }

  it { should contain_jenkins__plugin('git') }

  it { should contain_jenkins__plugin('git-client') }

  it { should contain_jenkins__plugin('ssh-agent') }

  it { should contain_jenkins__plugin('rebuild') }

  it { should contain_exec('acquia-jenkins-installed') }

  it { should contain_jenkins__user('admin') }
end
