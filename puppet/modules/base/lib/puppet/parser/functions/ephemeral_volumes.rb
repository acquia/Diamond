module Puppet::Parser::Functions
  newfunction(:ephemeral_volumes, :type => :rvalue) do |args|
    # Block devices list (should come from Facter)
    blockdevices = args.shift

    # Base path where we're going to mount the logical volumes
    mountpath = args.shift

    # FS to format
    fs_type = args.shift || 'ext4'

    # Remove xvda and xvdb from this list
    # xvdb is managed seperately from this scheme because it is mounted
    # under /mnt on some aws instances
    other_devices = blockdevices.split(',').reject{|dev| %w(xvda xvdb).include? dev}

    index = 1
    logical_vols = other_devices.reduce({}) do |acc, device|
      acc["ephemeral#{index}"] = {
        'mountpath' => "#{mountpath}/ephemeral#{index}",
        'fs_type' => fs_type,
        'size' => nil,
        'options' => 'defaults,nobootwait',
      }
      index += 1
      acc
    end

    logical_vols
  end
end
