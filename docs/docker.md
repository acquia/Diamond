# Docker
We use a [third-party](https://github.com/garethr/garethr-docker) Puppet module
for configuring Docker. If you do not want to have Docker installed then you
can disable it by adding the following snippet to the server type hiera file:

```yaml
docker::enabled: absent
```
