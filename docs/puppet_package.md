# Nemesis Puppet Package
We distribute Puppet modules by uploading an rpm package to an S3 bucket. This
package contains everything needed to set up a server using Nemesis.

## Versioning
The version number depends on the the value of the tags on the nemesis-puppet
repo and will have a timestamp automatically appended. A timestamp is not
appended if the `--release` flag is provided to the build command. In that case,
the version will be the value of the newest tag incremented by one. We use
[semantic versioning](http://semver.org/) as the versioning scheme for the
nemesis-puppet package.

If you have a version of `0.1.1` as the latest tag, then building the package
without the `--release` flag will produce a file called
`nemesis-puppet_0.1.1+${TIMESTAMP}_amd64.deb`.  If you use the `--release` flag,
then the file will be named `nemesis-puppet_0.1.2_amd64.deb`.

If you produce a release version then you should immediately tag the commit used
to produce the new package using an annotated tag.

    git tag -a ${VERSION} -m '${VERSION}'
    git push --tags origin master


## Building the Package
The nemesis-puppet docker container will build a puppet package for you and automatically
increment the version number.
