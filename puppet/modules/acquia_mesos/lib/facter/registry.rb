require 'facter'
require 'aws_helper'

if AwsHelper.server_type_is?('mesos')
  stack = AwsHelper.stack
  unless stack.nil?
    Facter.add('registry_endpoint') do
      setcode do
        registry_stack = AwsHelper::CloudFormation.stack(stack.parameter('RegistryStack'))
        endpoint = registry_stack.parameter('RegistryEndpoint')
        endpoint.end_with?('/') ? endpoint : "#{endpoint}/"
      end
    end
  end
end
