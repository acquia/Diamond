require 'aws-sdk'

module Puppet::Parser::Functions
  # Lookup an output result for a given CloudFormation stack.
  #
  # @param template [String] - CloudFormation Template name
  # @param output [String] - CloudFormation Output name
  # @return [AWS::CloudFormation::StackOutput] or nil
  newfunction(:cloudformation_output, :type => :rvalue) do |args|
    tempalate_name = args[0]
    output_name = args[1]

    cf = AWS::CloudFormation.new
    stack = cf.stacks[tempalate_name]

    output = stack.outputs.detect { |x| x.key == output_name }
    output
  end
end
