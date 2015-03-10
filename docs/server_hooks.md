# Nemesis Server Hooks
Puppet handles the majority of the instance-level configuration, but for tasks that are more complex we provide a simple API to execute scripts on the servers themselves.

## API
If you need to execute a custom script on that server, you can place a script in ```/etc/nemesis/server_hooks``` provided that it contains a class that conforms to the NemesisServer::Hook interface:

```ruby
#!/usr/bin/env ruby

class CustomHook < NemesisServer::Hook
  # Creates a new CloudwatchAlarms object.
  def initialize
    super
    @events = NemesisServer::HookManager::EVENT_INIT
    @version = '0.0.1'
    @interval = 30
  end

  # Implements NemesisServer::Hooks::execute.
  def execute
    # Execute your custom code here, note the logger is provided for you.
    @log.info "Something to note"
    "my output"
  end
end 

# Don't forget to register your hook.
NemesisServer::HookManager.register HookTwo.new
```

## Events
We currently track three events which determine if your script should run:

```ruby
# Execute only when the script has never been run.
@events = NemesisServer::HookManager::EVENT_INIT
# Execute only when the version number of your script changes.
@events = NemesisServer::HookManager::EVENT_UPDATE
# Execute on a regular interval.
@events = NemesisServer::HookManager::EVENT_REPEAT
```

These are set in the ```@events``` parameter of your class can be used as a bitmask if you wish to execute on more than one event, e.g. init and update.

If you wish to execute when your script is updated, use the ```@version``` parameter with the format "0.1.2".

To execute repeatedly, you can use the EVENT_REPEAT option and specify the ```@interval``` property as an integer representing the number of seconds since the last run. The API is run on cron, so this property does not guarantee execution on that interval, just that a minimum amount of time has passed since the last execution.

## Errors and response codes
The server hooks API will attempt to rerun your script if it fails. To denote success, return 0 from your execute method. Any non-zero return will tell the API that it needs to try again on the next run. The maximum number of attempts can be set on your object using the @max_consecutive_errors property, which defaults to 3.

## Locks and History
Since these tasks could be long running, we lock them in /var/lock/nemesis. We also store some basic information about the last execution so that the API can determine if the script is eligible to be run:

	{
	  'last_run' => 1424881927,
	  'hook_exit' => 0
	  'exec_count' => 10,
	  'consecutive_error_count' => 0,
	  'hook_version' => '0.0.1',
	  'api_version' => '0.0.1'
	}

## Logging
The API keeps a log of the script executions in /var/log/nemesis/server_hooks.log. This will have information about which hooks were executed and the state after each. The logger is assigned to the @log property of your object so that you may also add custom logging.

## Hook execution
The API is managed by the NemesisServer::HookManager class which is responsible for locating, locking and execution. It operates somewhat like a singleton, using a class instance variable to keep track of a shared instance. The reason it does this is so hooks can call the class method #register without needing a reference to the runtime instance. Starting the manager is done like the following example, which will locate all hooks and execute them.

```ruby
NemesisServer::HookManager.instance = NemesisServer::HookManager.new
NemesisServer::HookManager.instance.run
```
