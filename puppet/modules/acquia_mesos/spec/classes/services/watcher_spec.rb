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
end
