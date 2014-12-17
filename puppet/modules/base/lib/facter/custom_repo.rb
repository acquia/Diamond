require 'facter'
require 'aws-sdk'

Facter.add(:custom_repo) do
  setcode do
    cf = AWS::CloudFormation.new
    stack = cf.stack_resource(Facter.value('ec2_instance_id'))
    params = stack.stack.parameters
    params['RepoS3']
  end
end
