require 'facter'
require 'aws-sdk'

Facter.add(:custom_repo) do
  setcode do
    ec2 = AWS::EC2.new
    tags = ec2.instances[Facter.value('ec2_instance_id')].tags.to_h
    tags['repo']
  end
end
