require 'facter'
require 'aws-sdk'

ec2 = AWS::EC2.new

if ec2.instances[Facter.value('ec2_instance_id')].tags.to_h['server_type'] == 'graphite'
  cf = AWS::CloudFormation.new
  stack = cf.stack_resource(Facter.value('ec2_instance_id'))
  cassandra_stack_name = stack.stack.parameters['CassandraStack']

  if cassandra_stack_name

    # Return a list of all nodes in the cassandra cluster
    Facter.add('cassandra_nodes') do
      setcode do
        cassandra_cluster = []
        ["Seed", "Node"].each do |type|
          seed_autoscaling_group = cf.stacks[cassandra_stack_name].resources["Cassandra#{type}sAutoScalingGroup"].physical_resource_id
          autoscaling_group = AWS::AutoScaling::Group.new(seed_autoscaling_group)
          autoscaling_group.auto_scaling_instances.each { |i| cassandra_cluster << ec2.instances[i.id].ip_address }
        end

        cassandra_cluster.join(',')
      end
    end

    # Return the cassandra cql password
    Facter.add('cassandra_cql_password') do
      setcode do
        cql_password = cf.stacks[cassandra_stack_name].outputs.select{|output| output.key == 'CqlPassword'}
        (!cql_password.empty?) ? cql_password.first.value : nil
      end
    end

  end
end
