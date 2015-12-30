require 'spec_helper'

describe 'acquia_mesos::services::logstream', :type => :class do
  let(:facts) {
    {
      :logstream_name => 'TESTKINESIS-NAME',
      :ec2_placement_availability_zone => 'us-east-1a',
      :osfamily => 'redhat',
    }
  }

  let(:fluentd_conf) do
    <<EOF
<source>
  type forward
  port 24224
  bind 0.0.0.0
</source>

<match grid.**>
  type kinesis
  stream_name TESTKINESIS-NAME
  region us-east-1
  # TODO(mhrabovcin): Figure out partition once we'll figure how what tags we can provide from outside of docker container
  random_partition_key

  # Backup in case of kinesis going down will queue and re-try sending data to kinesis.
  # Data are stored on instance level and are available after container restart.
  # Buffer is set to 2GB (16m chunk size * 128 chunks)
  buffer_type file
  buffer_path /var/log/fluent/logstream*.buffer
  buffer_chunk_limit 16m
  buffer_queue_limit 128
  flush_interval 60s
  flush_at_shutdown true
  disable_retry_limit false
  retry_limit 17
  retry_wait 1s
</match>
EOF
  end

  it { should compile }

  it { should contain_class('acquia_mesos::services::logstream') }

  it {
    should contain_file('/etc/fluentd')
      .with({ 'ensure' => 'directory' })

    should contain_file('/etc/fluentd/logstream')
      .with({ 'ensure' => 'directory' })

    should contain_file('/etc/fluentd/logstream/td-agent.conf')
      .with_content(fluentd_conf)
      .that_notifies('Exec[fluentd-config-reload]')

    should contain_file('/mnt/log/logstream')
      .with({ 'ensure' => 'directory' })
  }

  describe 'runs correct fluentd container' do
    let(:facts) {
      super().merge({ :private_docker_registry => 'registry.example.com/' })
    }
    it {
      should contain_docker__run('logstream')
        .with({
                'image'            => 'registry.example.com/acquia/fluentd:latest',
                'volumes'          => [
                  '/etc/fluentd/logstream:/etc/td-agent',
                  '/mnt/log/logstream:/var/log/fluent/',
                ],
                'ports'            => ['24224'],
                'extra_parameters' => ['--restart=always', '-d', '--net=host', '--ulimit nofile=65536:65536', '--log-driver=syslog --log-opt syslog-facility=daemon --log-opt tag="logstream"'],
                'privileged'       => false,
                'restart_service'  => true,
                'pull_on_start'    => true,
              })
        .that_requires('File[/etc/fluentd/logstream/td-agent.conf]')
    }
  end

  describe 'reloads fluentd on configuration change' do
    let(:params) {
      {
        :docker_command => '/usr/bin/docker',
      }
    }
    it {
      should contain_exec('fluentd-config-reload')
        .with({
                'command'     => '/usr/bin/docker kill -s HUP logstream',
                'environment' => 'HOME=/root',
                'path'        => ['/bin', '/usr/bin'],
                'timeout'     => 0,
                'refreshonly' => true,
              })
    }
  end
end
