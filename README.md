# Nemesis-Ops
[![Build Status](https://magnum.travis-ci.com/acquia/nemesis-puppet.svg?token=fuZxkY8h1TVDnxYTXZSB&branch=master)](https://magnum.travis-ci.com/acquia/nemesis-puppet)

The `nemesis-ops` project (formerly known as `nemesis-puppet`) manages
Debian packages, creates Puppet manifests, and builds AMIs for
Nemesis-launched infrastructure.

Nemesis-Ops sits in the middle of a typical Nemesis workflow:

* `nemesis bootstrap` --- creates a *Nemesis repo*, stored in S3,
  which will be used to store packages and manifests for the rest of
  your Nemesis stacks.

* The Nemesis-Ops build scripts (in `packages/build_scripts`) build
  custom `deb` packages for your Nemesis stacks.

* `nemesis-ops package` --- uses [Aptly](http://www.aptly.info/) to
  upload the `deb` packages to your Nemesis repo, where `apt-get` can
  find them later.

* `nemesis-ops puppet build` --- assembles the `nemesis-puppet`
  package, a custom Puppet manifest for configuring your Nemesis
  stacks.

* `nemesis launch` --- launches CloudFormation stacks that configure
  themselves with the `nemesis-puppet` package (via EC2's `userdata`
  and `cloud-init`).

* `nemesis ami` --- bakes pre-configured AMIs.

For more detailed walkthroughs see the
[Nemesis](https://github.com/acquia/nemesis) documentation.

## Dependencies

Install and configure these tools before using `nemesis-ops`:

  - For managing `deb` packages: install `aptly`, `gnu-tar`, and `gpg`.
    - On the Mac: `brew install aptly gnu-tar gpg`

  - Install the Nemesis gem, or if you are actively developing the
    Nemesis gem, add its source to your `RUBYPATH`: `export
    RUBYLIB=$RUBYLIB:/sandbox/nemesis/lib`

  - To build `deb` packages, install Virtualbox and Vagrant.
    - [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
    - [Vagrant](https://www.vagrantup.com/downloads.html)

  - To build AMIs, install Packer.
    - On the Mac: `brew tap homebrew/binary && brew install packer`
    - Or, use
      [the command line installer](https://packer.io/downloads.html).

  - Install GPG (on the Mac: `brew install gnupg`). You may also want
    to set up `gpg-agent` to avoid repeatedly typing your GPG password
    when signing packages; see
    [Appendix A](#appendixa:usinggpg-agent), below.

  - Create a GPG key for signing packages, or obtain access to a
    key. If you generate a new key, you need to include the
    `nemesis-ops --gpg-key` flag to use that key. If you don't provide
    a GPG key, the default key (`23406CA7`) will be used.

    To generate a key:
    ````
    gpg --gen-key
    gpg --keyserver pgp.mit.edu --send-keys <KEY ID>
    ````

  - Setup AWS credentials. AWS has [instructions for configuring them on your machine.](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)

  - You need to set the `SECURE` environment variable to point to a
    credentials directory, and the `EC2_ACCOUNT` environment variable
    to the name of your account. (*Hint: if you're not using the
    credentials-export feature of `nemesis-puppet`, you can set these to
    fake values to get started -- mikeb.*) If you've set up Fields
    before, you should be all set.

## Setup

Go back to the nemesis-puppet folder and run:

    bundle install

## Building the packages

The Debian-package build system uses Vagrant and Docker to build all
packages: Vagrant launches an Ubuntu host, and each package is built
in a Docker container on that host. The build process leaves the
packages in the `./dist` directory.

To build every package:

    vagrant up
    vagrant ssh -c 'sudo -E su -c /vagrant/packages/build_scripts/build-all.sh'

(We intend to remove Vagrant from the build process eventually, but
are blocked by
[an issue with forwarding SSH keys into Docker on Mac OS X](https://github.com/docker/docker/issues/6396).)


## Managing the apt mirror

### Creating the mirror

    nemesis bootstrap ${stack_name}
    nemesis-ops package init ${stack_name}
    nemesis-ops puppet build ${stack_name}  # see the nemesis-puppet section, below
    nemesis-ops package upload ${stack_name}

These steps create an `apt` repo in S3, which defaults to being
private and is intended mainly for the private use of your Nemesis
stacks. `nemesis-puppet` automatically configures your newly-launched
instances to point to this repo.

### Adding a specific package

    nemesis-ops package add ${stack_name} path/to/*.deb

### Removing a specific package

    nemesis-ops package remove ${stack_name} path/to/*.deb


## Building the nemesis-puppet package

    nemesis-ops puppet build ${stack_name}

This creates a `deb` package named `nemesis-puppet` containing the
Puppet configuration for all the stacks supported by Nemesis. This
package then gets uploaded to your Nemesis repo along with the rest of
your private `deb` packages.

As an instance gets launched by Nemesis:

1. Its AWS userdata script directs the instance to run `cloud-init`.

2. `cloud-init` contacts the Nemesis repo in S3 and installs `puppet`
   and `nemesis-puppet`.

3. `cloud-init` calls `puppet apply`, which determines what sort of
   instance it's running on (using the instance's `server_type` tag),
   uses Facter and Heira to look up configuration for that instance,
   and runs Puppet to configure the instance.

If you've ever configured a Puppet Master, you'll probably be pleased
to know that Nemesis doesn't use one.

Consult the `docs` directory for more information on building and
versioning `nemesis-puppet`.

## Editing Nemesis Puppet manifests

The manifests used for configuring every Nemesis-launched instance
live in the `/puppet` subdirectory of this project.

## Building an AMI

By default, Nemesis-launched instances are launched from AWS base
AMIs, which are then configured in-place at launch time from
`nemesis-puppet.deb`. But you can also run `nemesis-puppet` to
configure an AMI which can be launched again and again.

Run the following commands to generate an AMI in a specified region.
Passing in a list of regions stores the AMI in the first region in the
list and copies it to the other regions once the build is complete.

    nemesis-ops ami build ${stack_name} \
      --tag <tag> \
      --regions=<list of regions> \
      --ami <existing ami id>

To just generate the ami template output run the following. (_Note: if
the file path in not passed in then the template will just be printed
to stdout._)

    nemesis-ops ami gen \
      --tag <tag> \
      --regions=<list of regions> \
      --ami <existing ami id> \
      /path/desired-output-file.json

## Appendix A: Using gpg-agent

If you want to avoid being prompted for your GPG key's password every
time you publish packages, you can run `gpg-agent`, the GPG equivalent
of `ssh-agent`.

1. Install the `gpg-agent` executable -- on the Mac, try `brew install gpg-agent`.
2. Edit `~/.gnupg/gpg-agent.conf`:

        allow-preset-passphrase
        max-cache-ttl 60480000
        default-cache-ttl 60480000
        pinentry-program /usr/local/bin/pinentry
        no-grab

3. Edit `~/.gnupg/gpg.conf`:

        use-agent  # Uncomment this line to enable it

4. Add to your `.bashrc`, or run manually:

        eval $(gpg-agent --daemon --allow-preset-passphrase)

# License

Except as otherwise noted this software is licensed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
