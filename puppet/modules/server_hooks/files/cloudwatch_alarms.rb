#!/usr/bin/env ruby

# Copyright 2014 Acquia, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'nemesis_aws_client'
require 'net/http'

# rubocop:disable ClassLength
class CloudwatchAlarms < NemesisServer::Hook
  SNS_TOPIC_NAME = 'platform-health-monitoring'

  # Locates the SNS topic ARN based on a specified topic name.
  #
  # @param topic_name [String] the name given to a topic.
  def locate_topic_arn(topic_name)
    client = NemesisAwsClient::SNS::Client.new
    complete = false
    topic_arn = ''
    response = client.list_topics
    until complete
      if topic_arn == '' && !response[:topics].empty?
        response[:topics].each do |topic|
          if topic[:topic_arn].match(/\:#{topic_name}$/)
            topic_arn = topic[:topic_arn]
            break
          end
        end
      end

      if !response[:next_token].nil?
        response = client.list_topics({ :next_token => response[:next_token] })
      else
        complete = true
      end
    end

    topic_arn
  end

  # Determines whether or not the alarm already exists.
  #
  # @param namespace [String] The namespce of the metric.
  # @param metric_name [String] The name of the metric.
  def alarm_exists?(namespace, metric_name)
    alarm = false
    client = NemesisAwsClient::CloudWatch::Client.new
    dimensions = get_alarm_dimensions
    response = client.describe_alarms_for_metric(
      {
        :metric_name => metric_name,
        :namespace => namespace,
        :dimensions => dimensions
      }
    )
    if response && !response.metric_alarms.empty?
      alarm = true
    end
    alarm
  end

  # Locates all alarms associated with this instance.
  def get_all_alarms
    client = NemesisAwsClient::CloudWatch::Client.new
    response = client.describe_alarms(
      {
        :alarm_name_prefix => create_alarm_name_prefix
      }
    )
  end

  # Generates the standard dimensions applied to alarms.
  def get_alarm_dimensions
    [{ :name => 'InstanceID', :value => @instance_id }]
  end

  # Generates the name for an alarm.
  #
  # @param namespace [String] The namespce of the metric.
  # @param metric_name [String] The name of the metric.
  def create_alarm_name(namespace, metric_name)
    prefix = create_alarm_name_prefix
    "#{prefix}--#{namespace}--#{metric_name}"
  end

  # Generates the prifix used to name the alarms.
  def create_alarm_name_prefix
    name = "nemesis--#{@stack_name}--#{@instance_id}"
  end

  # Creates a cloudwatch alarm with a specified number of retries in case of error.
  #
  # @param params [Hash] The required information for creating an alarm.
  #   :namespace [String]
  #   :metric_name [String]
  #   :period [String]
  #   :evaluation_periods [Numeric]
  #   :statistic [String]
  #   :threshold [Numeric]
  #   :comparison_operator [String]
  # @param retries [Int] The number of retries in case of error.
  # @param wait [Duration] The amount of time to wait between retries.
  def create_alarm_with_retries(params, retries = 3, wait = 10)
    success = false
    while retries > 0
      success = create_alarm params
      break if success
      sleep wait
      retries -= 1
    end

    success
  end

  # Creates a cloudwatch alarm.
  #
  # @param params [Hash] The required information for creating an alarm.
  #   :namespace [String]
  #   :metric_name [String]
  #   :period [String]
  #   :evaluation_periods [Numeric]
  #   :statistic [String]
  #   :threshold [Numeric]
  #   :comparison_operator [String]
  def create_alarm(params)
    return true if alarm_exists? params[:namespace], params[:metric_name]

    period = params.key?(:period) ? params[:period] : 300
    evaluation_periods = params.key?(:evaluation_periods) ? params[:evaluation_periods] : 3

    alarm_name = create_alarm_name params[:namespace], params[:metric_name]
    client = AWS::CloudWatch::Client.new
    dimensions = get_alarm_dimensions
    @log.info "Attempting to create #{alarm_name}"
    response = client.put_metric_alarm(
      {
        :alarm_name => alarm_name,
        :alarm_actions => [params[:topic_arn]],
        :insufficient_data_actions => [params[:topic_arn]],
        :metric_name => params[:metric_name],
        :namespace => params[:namespace],
        :statistic => params[:statistic],
        :dimensions => dimensions,
        :period => 300,
        :evaluation_periods => 3,
        :threshold => params[:threshold],
        :comparison_operator => params[:comparison_operator]
      }
    )
    @log.info "Create response was #{response.successful?}"

    alarm_exists? params[:namespace], params[:metric_name]
  end

  # Deletes all alarms associated with this instance.
  def delete_all_alarms
    current_alarms = get_all_alarms
    alarm_names = []
    current_alarms[:metric_alarms].each do |alarm|
      @log.info "Attempting to delete #{alarm[:alarm_name]}"
      alarm_names.push alarm[:alarm_name]
    end

    unless alarm_names.empty?
      client = NemesisAwsClient::CloudWatch::Client.new
      response = client.delete_alarms(
        {
          :alarm_names => alarm_names
        }
      )
      @log.info "Delete response was #{response.successful?}"
    end
  end

  # Creates a new CloudwatchAlarms object.
  def initialize
    super
    @events = NemesisServer::HookManager::EVENT_INIT | NemesisServer::HookManager::EVENT_UPDATE
    @version = '0.0.1'
    @interval = 1

    # Locate and track the AWS instance ID.
    metadata_endpoint = 'http://169.254.169.254/latest/meta-data/'
    @instance_id = Net::HTTP.get(URI.parse(metadata_endpoint + 'instance-id'))

    # Locate and track the current stack name.
    ec2 = NemesisAwsClient::EC2.new
    tags = ec2.instances[@instance_id].tags.to_h
    @stack_name = tags['aws:cloudformation:stack-name']
  end

  # Implements NemesisServer::Hooks::execute.
  def execute
    topic_arn = locate_topic_arn SNS_TOPIC_NAME
    @log.info "Using SNS topic ARN #{topic_arn} from topic name #{SNS_TOPIC_NAME}"

    delete_all_alarms

    alarm_creation_count = 0

    unless topic_arn.empty?
      Dir.chdir "#{@resource_location}alarms"
      Dir.glob('*.json').each do |filename|
        contents = File.read filename
        if contents.length > 2
          begin
            alarms = JSON.parse contents
            alarm_creation_count += alarms['alarms'].count
            alarms['alarms'].each do |alarm|
              created = create_alarm_with_retries(
                {
                  :metric_name => alarm['metric_name'],
                  :namespace => alarm['namespace'],
                  :topic_arn => topic_arn,
                  :statistic => alarm['statistic'],
                  :threshold => alarm['threshold'],
                  :comparison_operator => alarm['comparison_operator']
                }, 10, 30)
              @log.info "Testing that alarm exists '#{alarm['namespace']}:#{alarm['metric_name']}'. Output was #{created}."
              alarm_creation_count -= 1 if created
            end
          rescue JSON::ParserError => e
            @log.error "Unable to parse #{filename}: #{e.message}"
            # Add one to the count to ensure that the hook returns as a failure.
            alarm_creation_count += 1
          end
        end
      end
    end

    if alarm_creation_count == 0
      return 0
    else
      return 1
    end
  end
end

NemesisServer::HookManager.register CloudwatchAlarms.new
