require 'facter'
require 'aws-sdk'

Facter.add(:cassandra_backup_location) do
  setcode do
    cf = AWS::CloudFormation.new

    stack = cf.stack_resource(Facter.value('ec2_instance_id'))
    stack_name = stack.stack_name
    backup_location = cf.stacks[stack_name].resources['NemesisCassandraS3Backups'].physical_resource_id
    backup_location
  end
end
