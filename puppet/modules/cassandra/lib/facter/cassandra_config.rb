require 'facter'
require 'json'
require 'yaml'

Facter.add(:cassandra_config) do
  setcode do
    defualt_config_file = "/etc/cassandra/cassandra.yaml"
    overriders_file = "/etc/cassandra_overrides.json"

    # Load the Cassandra defualt config
    config = YAML.load(File.read(defualt_config_file))

    if File.exists?(overriders_file)
      # Load the json overrides
      overrides = JSON.parse(File.read(overriders_file))

      # Merge the overrides with the current defualt config
      config.merge!(overrides)
    end

    # return the updated config
    config.to_yaml
  end
end

