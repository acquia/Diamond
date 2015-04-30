require 'facter'
require 'nemesis_aws_client'

Facter.add(:cluster_name) do
  setcode do
    ec2 = NemesisAwsClient::EC2.new
    tags = ec2.instances[Facter.value('ec2_instance_id')].tags.to_h
    tags['aws:cloudformation:stack-name']
  end
end
