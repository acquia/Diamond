require "facter"
require "json"
require "yaml"

Facter.add(:cassandra_config) do
  setcode do
    defualt_config_file = "/etc/cassandra/cassandra.yaml"
    overriders_file = "/etc/cassandra_overrides.json"

    defaults = {
      "num_tokens" => 256,
      "max_hints_delivery_threads" => 8,
      "authenticator" => "AllowAllAuthenticator",
      "partitioner" => "org.apache.cassandra.dht.Murmur3Partitioner",
      "rpc_address" => "0.0.0.0",
      "commitlog_total_space_in_mb" => 2048,
      "memtable_flush_writers" => 2,
      "trickle_fsync" => true,
      "trickle_fsync_interval_in_kb" => 4096,
      "listen_address" => Facter.value("ec2_local_ipv4"),
      "rpc_server_type" => "hsha",
      "incremental_backups" => true,
      "concurrent_compactors" => 4,
      "multithreaded_compaction" => true,
      "endpoint_snitch" => "Ec2Snitch",
    }

    # Load the Cassandra defualt config
    config = YAML.load(File.read(defualt_config_file))
    config.merge!(defaults)

    if File.exists?(overriders_file)
      # Load the json overrides
      overrides_config = JSON.parse(File.read(overriders_file))

       overrides = {
         "cluster_name" => overrides_config["cluster_name"],
         "seed_provider" => [
          {
            "parameters" => [
              { "seeds" => overrides_config["seeds"] },
            ],
            "class_name" => "org.apache.cassandra.locator.SimpleSeedProvider",
          },
        ],
      }

      # Merge the overrides with the current defualt config
      config.merge!(overrides)
    end

    # return the updated config
    config.to_yaml
  end
end

