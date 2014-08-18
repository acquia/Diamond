require 'facter'
require 'aws-sdk'

Facter.add('cassandra_nodes') do
  setcode do
    cf = AWS::CloudFormation.new
    ec2 = AWS::EC2.new
    stack = cf.stack_resource(Facter.value(:ec2_instance_id)).stack
    cassandra_stack = stack.outputs.select{|o| o.key == 'CassandraStack'}.first.value
    cassandra_nodes = cf.stacks[cassandra_stack].outputs.select{|s| s.key == 'CassandraClusterList'}
    unless cassandra_nodes.empty?
      nodes = cassandra_nodes.first.value
      nodes.split(',').map{|s| "'#{ec2.instances[s].ip_address}:9160'"}.join(',')
    end
  end
end
