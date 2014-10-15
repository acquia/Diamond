require 'facter'
require 'aws-sdk'

Facter.add(:cassandra_seeds_list) do
  setcode do
    ec2 = AWS::EC2.new
    cf = AWS::CloudFormation.new

    stack_name = Facter.value('cloudformation_stackname')
    seeds_autoscaling_group_id = cf.stacks[stack_name].resources['CassandraSeedsAutoScalingGroup'].physical_resource_id
    autoscaling_group = Nemesis::Aws::Sdk::AutoScaling::Group.new(seeds_autoscaling_group_id)
    seeds = autoscaling_group.auto_scaling_instances.map { |i| ec2.instances[i.id].ip_address }

    # On initial launch of a stack if the current node is a seed then it could be the first seed up, if so
    # add itself to the list
    if Facter.value('cassandra_seed')
      seeds << Facter.value('ec2_public_ipv4')
    end

    seeds.uniq
  end
end
