require 'facter'
require 'aws_helper'
require 'secrets_helper'

stack = AwsHelper.stack
if stack
  secrets = SecretsHelper.new(stack)
  if secrets.enabled?
    Facter.add(:bugsnag_key) do
      setcode do
        secrets.get('bugsnag_key')
      end
    end
  end
end
