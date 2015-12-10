require 'facter'
require 'aws_helper'

Facter.add(:custom_repo) do
  setcode do
    AwsHelper.stack.parameter('RepoS3')
  end
end
