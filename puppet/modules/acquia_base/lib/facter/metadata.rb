# Expose all metadata passed to the instance as facts prefixed with 'acquia_'
# Also store a copy of the Acquia metadata as 'acquia_metadata'
require 'facter'
require 'json'
require 'aws_helper'

module AcquiaFacts
  def self.snakecase(str)
    return str.downcase if str =~ /^[A-Z_]+$/
    str.gsub(/\B[A-Z]/, '_\&').squeeze('_') =~ /_*(.*)/
    $+.downcase
  end

  def self.add_facts(metadata)
    Facter.add(:acquia_metadata) do
      setcode do
        metadata['Acquia']
      end
    end

    if metadata && metadata['Acquia']
      metadata['Acquia'].each do |key, value|
        Facter.add("acquia_#{snakecase(key)}".to_sym) do
          setcode do
            value
          end
        end
      end
    end
  end
end

stack_name_tag = AwsHelper.instance.tag('aws:cloudformation:stack-name')
logical_id_tag = AwsHelper.instance.tag('aws:cloudformation:logical-id')
if stack_name_tag && logical_id_tag
  metadata = AwsHelper::CloudFormation.stack(stack_name_tag).resource(logical_id_tag).metadata
  AcquiaFacts.add_facts(JSON.load(metadata)) if metadata
end
