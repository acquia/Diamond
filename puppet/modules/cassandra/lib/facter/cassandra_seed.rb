require 'facter'
require 'aws-sdk'

Facter.add(:cassandra_seed) do
  setcode do
    ec2 = AWS::EC2.new
    tags = ec2.instances[Facter.value('ec2_instance_id')].tags.to_h
    tags['seed'] == 'true'
  end
end
