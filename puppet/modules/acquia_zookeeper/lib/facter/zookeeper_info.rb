require 'facter'
require 'aws_helper'

if AwsHelper.server_type_is?('zookeeper')
  stack = AwsHelper.stack

  Facter.add('zk_config_location') do
    setcode do
      stack.resource('NemesisZookeeperS3Bucket').physical_resource_id
    end
  end

  Facter.add('zk_exhibitor_aws_access_key_id') do
    setcode do
      AwsHelper.credentials.access_key_id
    end
  end

  Facter.add('zk_exhibitor_aws_secret_access_key') do
    setcode do
      AwsHelper.credentials.secret_access_key
    end
  end

  Facter.add('zk_s3_prefix') do
    setcode do
      'exhibitor'
    end
  end

  Facter.add('zk_exhibitor_ui_password') do
    setcode do
      stack.parameter('ExhibitorUiPassword')
    end
  end
end
