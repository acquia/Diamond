require 'facter'
require 'aws-sdk'

Facter.add(:cloudwatch_enabled) do
  setcode do
    cf = AWS::CloudFormation.new
    stack = cf.stack_resource(Facter.value('ec2_instance_id'))
    params = stack.stack.parameters
    params['CloudwatchEnabled'] && params['CloudwatchEnabled'] == "enabled"
  end
end
