# Sumologic
There is a Sumologic module available that will install and configure a
Sumologic collector on any role or profile configured to include it.
Configuration for the log paths are set by configuring paths in Hiera.

## Adding to a profile
The Sumologic module can be pulled in using the `profiles::sumologic` class.

To add it to another profile:

```puppet
class profiles::sample {
  include sumologic
}
```
## Configuration
Configuration data to Sumologic is passed through Hiera. We use the
`sources.json` file to configure which paths the Sumologic collector needs to
watch. The paths are configured in the `sumologic::paths` key in Hiera. You
then need to provide a hash of paths and date formats keyed by a name.

```yaml
sumologic::paths:
  test_log:
    :path: '/var/log/test/test.log'
    :date_format: 'dd/MMM/yyyy HH:mm::ss'
  ...
```
Syslog and auth.log are automatically configured to be sent to Sumologic.

## Enabling Sumologic
The Sumologic credentials are stored on each server in a stack where
Sumologic is enabled. These credentials are encrypted and included
with nemesis-puppet when you build the package (details
[here](puppet_package)).

Sumologic is enabled on a stack-wide basis by launching or updating a
stack with the `--sumologic` flag. The argument is the account name
where you are launching your stack.
