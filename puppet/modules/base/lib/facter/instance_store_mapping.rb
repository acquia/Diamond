# A mapping of all instances that have instance storage
# @note: This needs to be kept up to date when AWS introduces new instance types
instance_store_mapping = [
  'c3.large',
  'c3.xlarge',
  'i2.2xlarge',
  'i2.4xlarge',
  'i2.8xlarge',
  'r3.2xlarge',
  'r3.4xlarge',
  'r3.8xlarge',
  'r3.large',
  'r3.xlarge',
]

# Some instance types already have their instance storage volumes mounted
# That list should go here so that we can avoid trying to format/mount existing
# volumes
xvdb_instance_store = [
  'c3.large',
  'c3.xlarge',
]

# These instance types have SSD instance storage with TRIM support
# This list tells us which instances need to have a cron job to run fstrim
trim_support_mapping = [
  'i2.2xlarge',
  'i2.4xlarge',
  'i2.8xlarge',
  'r3.2xlarge',
  'r3.4xlarge',
  'r3.8xlarge',
  'r3.large',
  'r3.xlarge',
]

Facter.add(:needs_blockdevices_mounted) do
  instance_type = Facter.value('ec2_instance_type')
  setcode do
    instance_store_mapping.include?(instance_type) ? true : false
  end
end

Facter.add(:supports_trim) do
  instance_type = Facter.value('ec2_instance_type')
  setcode do
    trim_support_mapping.include? instance_type ? true : false
  end
end

Facter.add(:aws_block_devices) do
  setcode do
    instance_type = Facter.value('ec2_instance_type')
    devices = Facter.value('blockdevices').split(',')
    extras = devices.reject { |dev| %w(xvda).include? dev }
    extras.delete 'xvdb' if xvdb_instance_store.include?(instance_type)
    extras.map { |dev| "/dev/#{dev}" }
    extras.size > 0 ? extras : nil
  end
end
