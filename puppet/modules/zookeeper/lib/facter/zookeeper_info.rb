require 'facter'
require 'aws-sdk'

ec2 = AWS::EC2.new

if ec2.instances[Facter.value('ec2_instance_id')].tags.to_h['server_type'] == 'zookeeper'
  cf = AWS::CloudFormation.new
  stack = cf.stack_resource(Facter.value('ec2_instance_id'))
  stack_name = stack.stack_name

  Facter.add('zk_config_location') do
    setcode do
      cf.stacks[stack_name].resources['NemesisZookeeperS3Bucket'].physical_resource_id
    end
  end

  Facter.add('zk_exhibitor_aws_access_key_id') do
    setcode do
      AWS::config.credentials[:access_key_id]
    end
  end

  Facter.add('zk_exhibitor_aws_secret_access_key') do
    setcode do
      AWS::config.credentials[:secret_access_key]
    end
  end

  Facter.add('zk_s3_prefix') do
    setcode do
      'exhibitor'
    end
  end

  Facter.add('zk_exhibitor_ui_password') do
    setcode do
      stack.stack.parameters['ExhibitorUiPassword']
    end
  end
end
