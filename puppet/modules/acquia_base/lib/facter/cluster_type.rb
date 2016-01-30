require 'facter'
require 'aws_helper'

Facter.add(:cluster_type) do
  setcode do
    AwsHelper.instance.tag('cluster_type')
  end
end
