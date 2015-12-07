require 'spec_helper'

describe 'acquia_mesos::master_api', :type => :class do
  let(:facts) {
    {
      :ec2_public_ipv4 => '10.0.0.1',
    }
  }
  it { should compile.with_all_deps }

  # The next line makes no sense, but is apparently needed to make
  # RSpec::Puppet recognize that acquia_mesos::master_api is
  # "covered" by specs.
  it { should contain_acquia_mesos__master_api }

  context 'installs and runs the grid-api docker container' do
    it { should contain_docker__image('acquia/grid-api').with_image_tag('latest') }

    it {
      should contain_docker__run('grid-api')
        .with_privileged(false)
        .with_env([
          'AG_REMOTE_SCHEDULER_HOST=10.0.0.1',
          'AG_REMOTE_SCHEDULER_PORT=8081',
        ])
    }
  end

  context 'adds logstream name to grid-api docker env' do
    let(:facts) {
      super().merge(:logstream_name => 'TEST_LOGSTREAM_NAME')
    }

    it {
      should contain_docker__run('grid-api')
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
