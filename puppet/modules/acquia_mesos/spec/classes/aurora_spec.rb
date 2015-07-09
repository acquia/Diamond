require 'spec_helper'

describe 'acquia_mesos::aurora', :type => :class do
  let(:facts) do
    {
      :operatingsystem => 'Ubuntu',
      :osfamily => 'Debian',
      :lsbdistcodename => 'trusty',
      :lsbdistid => 'Ubuntu',
      :mesos_cluster_name => 'test-cluster',
      :aurora_zookeeper_connection_string => '10.0.0.1:2181,10.0.0.2:2181',
    }
  end

  let(:cluster_json) do
    <<EOF
[{
  "name": "test-cluster",
  "zk": "10.0.0.1,10.0.0.2",
  "auth_mechanism": "UNAUTHENTICATED",
  "scheduler_zk_path": "/aurora/scheduler/",
  "slave_run_directory": "latest",
  "slave_root": "/mnt/lib/mesos"
}]
EOF
  end

  it { should compile }

  it { should contain_file('/etc/aurora') }
  it { should contain_file('/etc/aurora/clusters.json').with_content(cluster_json) }
end
