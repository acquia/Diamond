# Docker
We use a [third-party](https://github.com/garethr/garethr-docker) Puppet module
for configuring Docker. If you do not want to have Docker installed then you
can disable it by adding the following snippet to the server type hiera file:

```yaml
docker::enabled: absent
```

## Docker Garbage Collection

We use a [docker-gc](http://github.com/spotify/docker-gc) bash script that handles
purging stopped containers and unused images. This script is installed by default
with docker package and runs every hour. Default grace period for purging old
containers is 1 hour. This can be configured per instance with hiera where as value
you provide number of seconds:

```yaml
base::docker_gc::grace_period: 3600
```
