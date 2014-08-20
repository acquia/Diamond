class diamond::metrics_list{
  $jmx_objects = [
	{
	  'object_name' => 'org.apache.cassandra.db:type=CompactionManager',
	  'attributes' => ['TotalBytesCompacted','TotalCompactionsCompleted','CompletedTasks','PendingTasks']
	},
	{
	  'object_name' => 'org.apache.cassandra.db:type=ColumnFamilies,keyspace=system,columnfamily=peers',
	  'attributes' => ['TotalDiskSpaceUsed',]
	},
	{
	  'object_name' => 'org.apache.cassandra.db:type=Caches',
	  'attributes' => ['KeyCacheHits','RowCacheHits','KeyCacheRequests','RowCacheRequests','KeyCacheEntries','KeyCacheSize','']
	},
	{
	  'object_name' => 'org.apache.cassandra.db:type=ColumnFamilies,keyspace=system,columnfamily=IndexInfo',
	  'attributes' => ['LiveSSTableCount','TotalDiskSpaceUsed','TotalReadLatencyMicros','TotalWriteLatencyMicros']
	},
	{
	  'object_name' => 'org.apache.cassandra.db:type=StorageProxy',
	  'attributes' => ['WriteOperations','ReadOperations']
	},
  ]
}
