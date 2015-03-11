require 'facter'
require 'aws-sdk'

Facter.add(:cassandra_opscenter_address) do
  setcode do
    ec2 = AWS::EC2.new
    cf = AWS::CloudFormation.new

    if ec2.instances[Facter.value('ec2_instance_id')].tags.to_h['server_type'] == 'cassandra'
      stack = cf.stack_resource(Facter.value('ec2_instance_id'))
      stack_name = stack.stack_name
      ip = cf.stacks[stack_name].resources['OpsCenterEIP'].physical_resource_id
      ip
    end
  end
end
