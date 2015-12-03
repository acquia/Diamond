require 'aws-sdk'

# Provides methods for retrieving AWS SDK Resource objects for
# commonly used entities like CloudFormation stacks and EC2
# instances. Each entity's info is fetched once, and then a single
# object containing that info is returned thereafter.
#
# The Facter plugins in our various Puppet modules all tend to request
# the same information from the AWS SDK, and we don't want to make
# redundant API calls. We can leverage the design of the v2 AWS SDK if
# we have the Facter plugins share the same Resouce objects.
module AwsHelper
  # Return the current instance's Aws Config object.
  def self.config
    ::Aws::S3::Client.new.config
  end

  # Return the current instance's region.
  def self.region
    config.region
  end

  # Return the current instance's AWS credentials.
  def self.credentials
    config.credentials.credentials
  end

  module EC2
    # Return an Instance resource for the given instance ID, memoizing
    # the result.
    #
    # @param instance_id [string] An EC2 instance ID.
    # @return [Aws::EC2::Instance] an instance object, extended with InstanceExtensions.
    def self.instance(instance_id)
      @id_to_instance_map ||= {}
      @id_to_instance_map[instance_id] ||= ::Aws::EC2::Resource.new.instance(instance_id).extend(InstanceExtensions)
    end

    # Return multiple Instance resources for the given list of
    # instance IDs, memoizing the result.
    #
    # @param instance_ids [Array<string>] A list of EC2 instance IDs
    # @return [Array<Aws::EC2::Instance>] A list of instance objects, each
    #   extended with InstanceExtensions.
    def self.instances(instance_ids)
      @id_to_instance_map ||= {}
      results = []
      to_fetch = []
      instance_ids.each do |iid|
        if @id_to_instance_map[iid]
          results << @id_to_instance_map[iid]
        else
          to_fetch << iid
        end
      end
      if to_fetch.size > 0
        ::Aws::EC2::Resource.new.instances(instance_ids: to_fetch).each do |i|
          @id_to_instance_map[i.id] = i.extend(InstanceExtensions)
          results << i
        end
      end
      results
    end

    # Additional utility methods for an Aws::EC2::Instance.
    module InstanceExtensions
      # Return the value of the given instance tag, or nil if the tag is
      # not defined on the instance.
      #
      # @param key [string] Key for an instance tag
      # @return [string] Value of the tag, or nil.
      def tag(key)
        tag = tags.find { |t| t.key == key }
        tag.nil? ? nil : tag.value
      end
    end
  end

  module CloudFormation
    # Return the Stack with the given name, memoizing the result.
    #
    # The returned Stack will have extra utility methods from the
    # AwsHelper::CloudFormation::StackExtensions module.
    #
    # @return [Aws::CloudFormation::Stack] A stack, plus extra methods.
    def self.stack(name)
      @name_to_stack_map = {}
      @name_to_stack_map[name] ||= ::Aws::CloudFormation::Resource.new.stack(name).extend(StackExtensions)
    end

    # Return the Stack object that contains the resource with the given physical ID,
    # memoizing the result.
    #
    # Like the stack returned from #stack, the returned class will be extended
    # with AwsHelper::CloudFormation::StackExtensions
    #
    # @param physical_resource_id [string] A physical resource ID.
    # @return [Aws::CloudFormation::Stack] The stack containing the resource
    def self.stack_containing_resource(physical_resource_id)
      @resource_to_stack_map ||= {}
      return @resource_to_stack_map[physical_resource_id] if @resource_to_stack_map.include?(physical_resource_id)
      rs = ::Aws::CloudFormation::Client.new.describe_stack_resources(physical_resource_id: physical_resource_id)
      return nil unless rs.stack_resources.length > 0
      @resource_to_stack_map[physical_resource_id] = stack(rs.stack_resources.first.stack_name).extend(StackExtensions)
    end

    # Additional utility methods for an Aws::CloudFormation::Stack.
    module StackExtensions
      # Return the value of the given parameter, or nil if the parameter is
      # not defined on the stack.
      #
      # @param key [string] Key for a stack parameter.
      # @return [string] Value of the parameter, or nil.
      def parameter(key)
        p = parameters.find { |x| x.parameter_key == key }
        p.nil? ? nil : p.parameter_value
      end
    end
  end

  module AutoScaling
    # Return the AutoScalingGroup with the given name, memoizing the result.
    #
    # @param group_name [string] A group name.
    # @return [Aws::AutoScaling::Types::AutoScalingGroup]
    def self.group_for_name(group_name)
      @group_for_name ||= {}
      unless @group_for_name.include?(group_name)
        c = ::Aws::AutoScaling::Client.new
        groups = c.describe_auto_scaling_groups(auto_scaling_group_names: [group_name]).auto_scaling_groups
        return nil if groups.size == 0
        @group_for_name[group_name] = groups.first
      end
      @group_for_name[group_name]
    end
  end

  # Utilities for use inside Facter plugins on a Nemesis instance.

  # Return the Aws::EC2::Instance object which represents the current instance.
  #
  # @return [Aws::EC2::Instance] An Instance, augmented with InstanceExtensions methods.
  def self.instance
    EC2.instance(Facter.value('ec2_instance_id'))
  end

  # Return the Aws::CloudFormation::Stack which contains the current
  # instance.
  #
  # @return [Aws::CloudFormation::Stack] A Stack, augmented with StackExtensions methods.
  def self.stack
    CloudFormation.stack_containing_resource(Facter.value('ec2_instance_id'))
  end

  # @param [string] The value of a server_type tag.
  # @return [Boolean] Is the current instance of the given server_type
  def self.server_type_is?(server_type)
    instance.tag('server_type') == server_type
  end
end
