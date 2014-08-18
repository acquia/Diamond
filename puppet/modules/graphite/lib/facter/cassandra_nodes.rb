require "json"

Facter.add('cassandra_nodes') do
  setcode do
    config_file = "/etc/graphite.json"
    nodes = ""
    if File.exists?(config_file)
      # Load the json overrides config
      config = JSON.parse(File.read(config_file))
      nodes = config['cassandra_cluster']
    end
    nodes
  end
end
