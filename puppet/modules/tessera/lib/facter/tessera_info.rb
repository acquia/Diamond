require 'facter'
require 'aws-sdk'

ec2 = AWS::EC2.new

if ec2.instances[Facter.value('ec2_instance_id')].tags.to_h['server_type'] == 'tessera'
  cf = AWS::CloudFormation.new
  stack = cf.stack_resource(Facter.value('ec2_instance_id'))
  params = stack.stack.parameters
  graphite_stack = cf.stacks[params['GraphiteStack']]

  Facter.add('graphite_cluster') do
    setcode do
      graphite_stack.outputs.select { |s| s.key == 'GraphiteELB' }.first.value
    end
  end

  Facter.add('tessera_master_username') do
    setcode do
      params['TesseraMasterUsername']
    end
  end

  Facter.add('tessera_master_password') do
    setcode do
      params['TesseraMasterPassword']
    end
  end

  Facter.add('tessera_rds_endpoint_address') do
    setcode do
      begin
        rds_db = cf.stack_resource(stack.stack_name, 'TesseraRDSDB')
        rds = AWS::RDS::DBInstance.new(rds_db.physical_resource_id)
        rds.endpoint_address
      rescue
        nil
      end
    end
  end

  Facter.add('tessera_web_ui_username') do
    setcode do
      params['TesseraUiUsername']
    end
  end

  Facter.add('tessera_web_ui_password') do
    setcode do
      params['TesseraUiPassword']
    end
  end

  Facter.add('tessera_dbname') do
    setcode do
      params['TesseraDBName']
    end
  end

  Facter.add('tessera_graphite_token') do
    setcode do
      graphite_stack.parameters['GraphiteToken']
    end
  end

  Facter.add('tessera_graphite_password') do
    setcode do
      graphite_stack.parameters['GraphiteUiPassword']
    end
  end
end
