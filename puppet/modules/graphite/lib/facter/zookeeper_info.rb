require 'facter'
require 'nemesis_aws_client'

ec2 = NemesisAwsClient::EC2.new

if ec2.instances[Facter.value('ec2_instance_id')].tags.to_h['server_type'] == 'graphite'
  cf = NemesisAwsClient::CloudFormation.new
  stack = cf.stack_resource(Facter.value('ec2_instance_id'))
  zk_stack_name = stack.stack.parameters['ZookeeperStack']

  if zk_stack_name
    zk_stack = cf.stacks[zk_stack_name]
    asg = zk_stack.resources['ZookeeperAutoScalingGroup'].physical_resource_id
    autoscaling_group = NemesisAwsClient::AutoScaling::Group.new(asg)

    Facter.add('zookeeper_nodes') do
      setcode do
        instances = autoscaling_group.auto_scaling_instances.map { |i| ec2.instances[i.id].ip_address }
        instances.join(',')
      end
    end

    Facter.add('zookeeper_private_ips') do
      setcode do
        private_ips = autoscaling_group.auto_scaling_instances.map { |i| ec2.instances[i.id].private_ip_address }
        private_ips.join(',')
      end
    end
  end
end
