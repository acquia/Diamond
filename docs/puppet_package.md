# Nemesis Puppet Package
We distribute Puppet modules by uploading a .deb package to an S3 bucket. This
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

## Encrypted Data
Some Puppet modules may require credentials or other secure data to be present
on the filesystem to properly configure a server. NemesisOps uses the
[hiera-eyaml](https://github.com/TomPoulton/hiera-eyaml) gem along with the
[hiera-eyaml-gpg](https://github.com/sihil/hiera-eyaml-gpg) extension to bundle
GPG encrypted data that can be decrypted by the Pupppet process.

The build process creates a GPG keyring along with a single GPG key that is used
for both encrypting and decrypting secure data. This keyring is distributed in
the nemesis-puppet package and lives in `/etc/puppet/.gnupg`. Since we have to
distribute the secret key without a passphrase in order for Puppet to be able to
use it, we generate a new key and keyring each time the nemesis-puppet package
is built. This allows you to switch away from using a comprimised key simply by
releasing a new version of the package. The goal is to make sure that secure
data is not accessable on the filesystem without having root access to the
server.

### Secure Data Files
Data you want to distribute should be stored as yaml files in the $SECURE
directory in a folder called nemesis. The subfolders in the nemesis directory
should be named according to the AWS account you want to use them with. Each
yaml file name should match the module you want to use it with.

A filesystem layout for distributing data to the Sumologic module would then
resemble the following:

    /path/to/secure/directory
    └── nemesis
      ├── hosting-dev
      │   └── sumologic.yaml
      └── platform-health
          └── sumologic.yaml

Each yaml file should contain data structued in the way that Puppet expects data
to be made available to modules. For example, the Sumologic module expects
a parameter `sumologic::credentials` that defines a username and password. An
example of that structure would look like

    ---
    sumologic::credentials:
      username: gerhard_jenkins 
      password: w356pzeb

where you would substitute the appropriate username and password values.

Only the values are encrypted and all keys are left in plain-text. This means
that you should structure your data so that you do not have secure data as keys.

In this example, only the `encrypted_data` value will be encrypted. The keys in
the hash will be left as plain-text.

    ---
    some_module::insecure_data
      some_value_that_is_not_encrypted:
        still_not_encrypted: encrypted_data


## Building the Package
The `nemesis-ops` tool will build a puppet package for you and automatically
increment the version number.
