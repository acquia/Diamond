# CloudWatch Monitoring.
We use a diamond handler to send metrics to cloudwatch. Our operational monitoring happens in the form of cloudwatch alarms. The alarms are created for new instances using our [server hooks api](server_hooks.md) when an instance is launched or we update the list of alarms.

We employ a server hook script to locate alarm lists distributed by nemesis-puppet and attempt to install them. The hook will look in ```/etc/nemesis/resources/alarms``` for json-encoded files with a .json file extension. All alarms defined in these files will be created:

	{"alarms":
	  [
	    {
	      "period": 300,
	      "evaluation_periods": 3,
	      "metric_name": "MemFree",
	      "namespace": "Memory",
	      "statistic": "Minimum",
	      "threshold": 500000,
	      "comparison_operator": "LessThanThreshold"
	    }
	  }
	}

The parameters and their values are directly taken from the AWS CloudWatch API, please see the AWS documentation for the allowed values.
