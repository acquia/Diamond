require 'spec_helper'

describe 'acquia_mesos::master_api', :type => :class do
  it { should compile.with_all_deps }

  context 'installs and runs the grid-api docker container' do
    it { should contain_docker__image('acquia/grid-api').with_image_tag('latest') }

    it {
      should contain_docker__run('grid-api')
        .with_privileged(false)
    }
  end
end
