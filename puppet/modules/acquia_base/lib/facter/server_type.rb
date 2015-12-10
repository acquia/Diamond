require 'facter'
require 'aws_helper'

Facter.add(:server_type) do
  setcode do
    AwsHelper.instance.tag('server_type')
  end
end
