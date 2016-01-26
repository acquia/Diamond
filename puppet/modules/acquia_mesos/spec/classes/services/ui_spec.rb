require 'spec_helper'

describe 'acquia_mesos::services::ui', :type => :class do
  let(:facts) {
    {
      :osfamily => 'RedHat',
      :operatingsystemrelease => '7',
    }
  }

  it { should compile.with_all_deps }

  it { should contain_acquia_mesos__services__ui }

  describe 'contains docker puppet module' do
    it {
      should contain_file('/usr/local/bin/update_docker_image.sh')
    }
  end

  context 'pulls the correct version of the mesos-ui container' do
    let(:params) {
      {
        :version => '1.0'
      }
    }
    it {
      should contain_docker__image('capgemini/mesos-ui')
        .with_image_tag('1.0')

      should contain_docker__run('mesos-ui')
        .with_image('capgemini/mesos-ui:1.0')
    }
  end
end
