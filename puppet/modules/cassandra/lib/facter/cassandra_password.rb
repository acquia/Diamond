require 'facter'
require 'aws-sdk'

ec2 = AWS::EC2.new

server_type = ec2.instances[Facter.value('ec2_instance_id')].tags.to_h['server_type']
if server_type == 'cassandra' || server_type == 'opscenter'
  Facter.add('cassandra_cql_password') do
    setcode do
      cf = AWS::CloudFormation.new
      stack = cf.stack_resource(Facter.value('ec2_instance_id')).stack
      stack.parameters['CqlPassword']
    end
  end
end
