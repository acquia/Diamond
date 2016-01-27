require 'spec_helper'

describe 'acquia_ecs', :type => :class do
  let(:facts) {
    {
      :osfamily => 'redhat',

      :ecs_cluster_name => 'test',
      :docker_registry_url => 'index.docker.io',
      :docker_registry_auth => '0123456789',
      :docker_registry_email => 'foo@example.com',
      :docker_min_port => '32768',
      :docker_max_port => '61000',
    }
  }

  it { should compile.with_all_deps }

  context 'creates all necessary directories' do
    it { should contain_file('/var/lib/ecs') }
    it { should contain_file('/var/lib/ecs/data') }
    it { should contain_file('/var/log/ecs') }
  end

  context 'configures the aws ecs agent' do
    let(:ecs_engine_auth) {
      %r(ECS_ENGINE_AUTH_DATA={"https://index.docker.io/v1/":{"auth":"0123456789","email":"foo@example.com"}})
    }

    it {
      should contain_file('/etc/ecs/ecs.config')
        .with_content(/ECS_CLUSTER=test/)
        .with_content(ecs_engine_auth)
    }

    it { should contain_sysctl('net.ipv4.ip_local_port_range').with('value' => '32768 61000') }

    it { should contain_file('/usr/local/bin/update_docker_image.sh') }

    it { should contain_docker__image('amazon/amazon-ecs-agent').with_image_tag('latest') }

    it {
      should contain_docker__run('ecs-agent')
        .with_env_file('/etc/ecs/ecs.config')
        .with_privileged(true)
    }
  end
end
