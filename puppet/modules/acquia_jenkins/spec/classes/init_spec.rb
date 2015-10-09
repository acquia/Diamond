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
      :jenkins_url => 'jenkins.example.com',
      :path => '/bin:/usr/bin:/usr/local/sbin'
    }
  }

  it { should compile.with_all_deps }

  it {
    should contain_class('acquia_jenkins')
    should contain_class('jenkins::cli_helper')
  }

  it { should contain_package('bundler') }

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

    should contain_file('/mnt/acquia_grid_ci_dist').with(
      'owner' => 'jenkins',
      'group' => 'jenkins'
    )

    should contain_file('/var/lib/jenkins').with(
      'owner' => 'jenkins',
      'group' => 'jenkins'
    )

    should contain_file('/var/lib/jenkins/.ssh').with(
      'owner' => 'jenkins',
      'group' => 'jenkins'
    )

    should contain_file('/var/lib/jenkins/.ssh/config').with(
      'owner' => 'jenkins',
      'group' => 'jenkins'
    )

    should contain_file('/var/lib/jenkins/.ssh/github.pub').with(
      'owner' => 'jenkins',
      'group' => 'jenkins'
    )

    should contain_file('/var/lib/jenkins/users').with(
      'owner' => 'jenkins',
      'group' => 'jenkins'
    )

    should contain_file('/var/lib/jenkins/users/admin').with(
      'owner' => 'jenkins',
      'group' => 'jenkins'
    )

    should contain_file('/var/lib/jenkins/config.xml').with(
      'owner' => 'jenkins',
      'group' => 'jenkins'
    )

    should contain_file('/var/lib/jenkins/users/admin/config.xml').with(
      'owner' => 'jenkins',
      'group' => 'jenkins'
    )

    should contain_file('/opt/grid-ci').with(
      'ensure' => 'directory',
      'owner' => 'jenkins',
      'group' => 'jenkins'
    )

    should contain_file('/var/lib/jenkins/jobs').with(
      'ensure' => 'symlink',
      'owner' => 'jenkins',
      'group' => 'jenkins'
    )
  }

  it {
    should contain_vcsrepo('/opt/grid-ci').with(
      'ensure'   => 'present',
      'provider' => 'git',
      'source'   => 'git@github.com:kasisnu/grid-ci'
    )
  }

  it {
    should contain_exec('create-jenkins-cli-key')
    should contain_exec('acquia-jenkins-installed')
  }

  it { should contain_jenkins__user('admin') }

  it {
    should contain_jenkins__plugin('authentication-tokens')
    should contain_jenkins__plugin('build-token-root')
    should contain_jenkins__plugin('ci-skip')
    should contain_jenkins__plugin('credentials')
    should contain_jenkins__plugin('credentials-binding')
    should contain_jenkins__plugin('docker-build-publish')
    should contain_jenkins__plugin('docker-commons')
    should contain_jenkins__plugin('durable-task')
    should contain_jenkins__plugin('ec2')
    should contain_jenkins__plugin('git')
    should contain_jenkins__plugin('git-client')
    should contain_jenkins__plugin('git-server')
    should contain_jenkins__plugin('google-login')
    should contain_jenkins__plugin('greenballs')
    should contain_jenkins__plugin('groovy')
    should contain_jenkins__plugin('mailer')
    should contain_jenkins__plugin('mapdb-api')
    should contain_jenkins__plugin('matrix-project')
    should contain_jenkins__plugin('node-iterator-api')
    should contain_jenkins__plugin('parameterized-trigger')
    should contain_jenkins__plugin('plain-credentials')
    should contain_jenkins__plugin('promoted-builds')
    should contain_jenkins__plugin('rebuild')
    should contain_jenkins__plugin('ruby-runtime')
    should contain_jenkins__plugin('scm-api')
    should contain_jenkins__plugin('script-security')
    should contain_jenkins__plugin('ssh-agent')
    should contain_jenkins__plugin('ssh-credentials')
    should contain_jenkins__plugin('token-macro')
    should contain_jenkins__plugin('workflow-api')
    should contain_jenkins__plugin('workflow-basic-steps')
    should contain_jenkins__plugin('workflow-cps')
    should contain_jenkins__plugin('workflow-cps-global-lib')
    should contain_jenkins__plugin('workflow-durable-task-step')
    should contain_jenkins__plugin('workflow-job')
    should contain_jenkins__plugin('workflow-scm-step')
    should contain_jenkins__plugin('workflow-step-api')
    should contain_jenkins__plugin('workflow-support')
    should contain_jenkins__plugin('workflow-aggregator')
  }
end
