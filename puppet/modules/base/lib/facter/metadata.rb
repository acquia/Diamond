# Expose all metadata passed to the instance as facts prefixed with 'acquia_'
# Also store a copy of the Acquia metadata as 'acquia_metadata'
require 'facter'
require 'aws-sdk'
require 'json'

module AcquiaFacts
  def snakecase(str)
    return str.downcase if str =~ /^[A-Z_]+$/
    str.gsub(/\B[A-Z]/, '_\&').squeeze("_") =~ /_*(.*)/
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

ec2 = AWS::EC2.new
cf = AWS::CloudFormation.new

tags = ec2.instances[Facter.value('ec2_instance_id')].tags.to_h
stack = cf.stacks[tags['aws:cloudformation:stack-name']]
metadata = stack.resources[tags['aws:cloudformation:logical-id']].metadata
if metadata
  metadata = JSON.load(metadata)
  AcquiaFacts.add_facts(metadata)
end

