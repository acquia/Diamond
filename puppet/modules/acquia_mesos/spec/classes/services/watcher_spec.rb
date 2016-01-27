require 'spec_helper'

describe 'acquia_mesos::services::watcher', :type => :class do
  let(:facts) {
    {
      :osfamily => 'RedHat',
      :operatingsystemrelease => '7',
    }
  }

  it { should compile.with_all_deps }

  it { should contain_acquia_mesos__services__watcher }

  context 'contains docker puppet module' do
    it {
      should contain_file('/usr/local/bin/update_docker_image.sh')
    }
  end

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
        .with_ports(['6677:6677'])
    }
  end

  context 'adds baragon to grid-watcher docker env' do
    let(:facts) {
      super().merge(
        {
          :aurora_zookeeper_connection_string => '10.0.0.1:2181,10.0.0.2:2181',
        }
      )
    }

    let(:params) {
      {
        :watcher_host => '10.0.0.1',
        :watcher_port => 8081,
        :baragon_host => '10.0.0.2',
        :baragon_port => 8080,
      }
    }

    it {
      should contain_docker__run('grid-watcher')
        .with_env([
          'ALB_HOST=10.0.0.1',
          'ALB_PORT=8081',
          'ALB_ZK_SERVERS=10.0.0.1:2181,10.0.0.2:2181',
          'ALB_BARAGON_API=http://10.0.0.2:8080/baragon/v2',
        ])
    }
  end
end
