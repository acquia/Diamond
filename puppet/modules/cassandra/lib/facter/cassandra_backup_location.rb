require 'facter'
require 'nemesis_aws_client'

Facter.add(:cassandra_backup_location) do
  setcode do
    ec2 = NemesisAwsClient::EC2.new
    cf = NemesisAwsClient::CloudFormation.new

    if ec2.instances[Facter.value('ec2_instance_id')].tags.to_h['server_type'] == 'cassandra'
      stack = cf.stack_resource(Facter.value('ec2_instance_id'))
      stack_name = stack.stack_name
      backup_location = cf.stacks[stack_name].resources['NemesisCassandraS3Backups'].physical_resource_id
      backup_location
    end
  end
end
