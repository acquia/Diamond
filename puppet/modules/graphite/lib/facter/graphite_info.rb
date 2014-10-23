require 'facter'
require 'aws-sdk'

ec2 = AWS::EC2.new

if ec2.instances[Facter.value('ec2_instance_id')].tags.to_h['server_type'] == 'graphite'
  cf = AWS::CloudFormation.new
  stack = cf.stack_resource(Facter.value('ec2_instance_id'))
  params = stack.stack.parameters

  Facter.add('graphite_password') do
    setcode do
      params['GraphiteUiPassword']
    end
  end

  Facter.add('graphite_token') do
    setcode do
      params['GraphiteToken']
    end
  end
end