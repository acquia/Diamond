require 'facter'
require 'aws_helper'

Facter.add(:stack_name) do
  setcode do
    AwsHelper.instance.tag('aws:cloudformation:stack-name')
  end
end
