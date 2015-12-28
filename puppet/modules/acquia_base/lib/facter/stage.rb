require 'facter'
require 'aws_helper'

Facter.add(:stage) do
  setcode do
    AwsHelper.instance.tag('stage')
  end
end
