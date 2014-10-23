require 'facter'
require 'aws-sdk'

cf = AWS::CloudFormation.new
ec2 = AWS::EC2.new
stack = cf.stack_resource(Facter.value('ec2_instance_id'))
cassandra_stack_name = stack.stack.parameters['CassandraStack']
seed_autoscaling_group = cf.stacks[cassandra_stack_name].resources['CassandraSeedsAutoScalingGroup'].physical_resource_id
autoscaling_group = AWS::AutoScaling::Group.new(seed_autoscaling_group)
seeds = []
autoscaling_group.auto_scaling_instances.each { |i| seeds << ec2.instances[i.id].ip_address }

cql_password = cf.stacks[cassandra_stack_name].outputs.select{|output| output.key == 'CqlPassword'}.first.value

Facter.add('cassandra_nodes') do
  setcode do
    seeds
  end
end

Facter.add('cassandra_cql_password') do
  setcode do
    cql_password
  end
end

