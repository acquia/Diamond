require 'facter'
require 'aws-sdk'

Facter.add(:cassandra_backup_location) do
  setcode do
    cf = AWS::CloudFormation.new

    stack_name = Facter.value('cloudformation_stackname')
    backup_location = cf.stacks[stack_name].resources['NemesisCassandraS3Backups'].physical_resource_id
    backup_location
  end
end
