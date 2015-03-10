# Acquia Metadata Facts
Stacks launched from nemesis [with Acquia metadata](https://github.com/acquia/nemesis/blob/master/docs/metadata.md) expose that data to puppet as facts in two ways: a) a hash of all metadata and b) individual properties as separate facts.

## Accessing the entire metadata hash

	$acquia_metadata

## Accessing individual properties
There is a slight conversion that happens to the keys stored in the nemesis template before they become facts. They are first prefixed with "acquia_". If the key is camelcase, it will get converted to snake case. e.g. "MyMetaData" will be exposed as "$acquia_my_meta_data".

If the metadata was provided by a nemesis option:

	@@metadata_options.add(:cloudwatch, :boolean, "Send data to cloudwatch", default: false)

The option key ":cloudwatch" will be stored in the template metadata and you will be able to access it via facter as "$acquia_cloudwatch".
	
