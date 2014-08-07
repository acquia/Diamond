module Puppet::Parser::Functions
  # Lookup a CloudFormation stack name based on Ec2 instance id.
  #
  # @param id [String] - Ec2 instace id
  # @return [String] - CloudFormation stack name or nil
  newfunction(:cloudformation_stackname, :type => :rvalue) do |args|
    instance_id = args[0]
    begin
      cf = AWS::CloudFormation.new
      stack = cf.stack_resource(instance_id)
      stack.stack_name
    rescue
      nil
    end
  end
end
