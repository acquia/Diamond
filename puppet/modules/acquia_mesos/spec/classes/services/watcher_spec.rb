require 'spec_helper'

describe 'acquia_mesos::services::watcher', :type => :class do
  let(:facts) {
    {
      :osfamily => 'redhat',
    }
  }

  it { should compile.with_all_deps }

  it { should contain_acquia_mesos__services__watcher }

  context 'installs and runs the grid-watcher docker container' do
    it {
      should contain_docker__image('acquia/grid-watcher')
        .with_image_tag('latest')

      should contain_docker__run('grid-watcher')
        .with_privileged(false)
        .with_image('acquia/grid-watcher:latest')
    }
  end

  context 'pulls the grid-watcher container from a remote registry' do
    let(:facts) {
      super().merge(
        {
          :private_docker_registry => 'registry.example.com/'
        }
      )
    }
    it {
      should contain_docker__run('grid-watcher')
        .with_image('registry.example.com/acquia/grid-watcher:latest')
    }
  end

  context 'pulls the correct version of the grid-watcher container' do
    let(:params) {
      {
        :version => '1.0'
      }
    }
    it {
      should contain_docker__run('grid-watcher')
        .with_image('acquia/grid-watcher:1.0')
        .with_ports(['6677'])
    }
  end

  context 'adds logstream name to grid-watcher docker env' do
    let(:facts) {
      super().merge(
        {
          :logstream_name => 'TEST_LOGSTREAM_NAME',
          :ec2_public_ipv4 => '10.0.0.1'
        }
      )
    }

    it {
      should contain_docker__run('grid-watcher')
        .with_env([
          'AG_REMOTE_SCHEDULER_HOST=10.0.0.1',
          'AG_REMOTE_SCHEDULER_PORT=8081',
          'AG_LOGSTREAM=1',
          'AG_LOGSTREAM_DRIVER=fluentd',
          'AG_LOGSTREAM_DRIVER_OPTS=fluentd-address=0.0.0.0:24224',
          'AG_LOGSTREAM_TAG_PREFIX=grid',
        ])
    }
  end
end
