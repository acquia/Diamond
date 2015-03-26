require 'facter'
require 'nemesis_aws_client'

Facter.add(:custom_repo) do
  setcode do
    cf = NemesisAwsClient::CloudFormation.new
    stack = cf.stack_resource(Facter.value('ec2_instance_id'))
    params = stack.stack.parameters
    params['RepoS3']
  end
end
