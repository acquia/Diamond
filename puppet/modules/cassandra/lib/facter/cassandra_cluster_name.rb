require 'facter'
require 'aws-sdk'

Facter.add(:cassandra_cluster_name) do
  setcode do
    ec2 = AWS::EC2.new
    tags = ec2.instances[Facter.value('ec2_instance_id')].tags.to_h
    tags['cluster_name']
  end
end
