# Nemesis Package Manager
[![Build Status](https://magnum.travis-ci.com/acquia/nemesis-puppet.svg?token=fuZxkY8h1TVDnxYTXZSB&branch=master)](https://magnum.travis-ci.com/acquia/nemesis-puppet)
APT Packages manager and Puppet manifests used with Nemesis


## Dependencies
Dependencies needed to be installed and configured before working with the
Nemesis Package Manager:

  * Install dependencies
    - Common Dependencies: aptly gnu-tar gpg
      * Mac: brew install aptly gnu-tar gpg

    - Install Virtualbox
      * https://www.virtualbox.org/wiki/Downloads
    - Install Vagrant
      * https://www.vagrantup.com/downloads.html
    - Install Packer
      * Mac: brew tap homebrew/binary && brew install packer

  * Setup GPG key for signing packages. If you generate a new key, you
    need to use the `nemesis-ops --gpg-key` flag to use that generated key.
    If no key is provided then the default key used is 23406CA7.

    ````
    gpg --gen-key
    gpg --keyserver pgp.mit.edu --send-keys <KEY ID>
    ````

  * Setup AWS credentials and ssh keys
  * Install the Nemesis gem or add to your RUBYPATH
    *  export RUBYLIB=$RUBYLIB:/sandbox/nemesis/lib


## Setup

You need to ensure that the environment variables $SECURE and $EC2_ACCOUNT are
set to valid values. If you have already set up Nemesis or Fields then you
should not need to do anything.

Go back to the nemesis-puppet folder

    bundle install


## Building the packages
The package build system uses Vagrant and Docker as its main components for
building all packages. Vagrant launches a base ubuntu host and Docker
containers are used to isolate each script. The resulting package from each
script is left in the ./dist directory.

NOTE: Currently builds using local Docker on OS X do not work due to and issue
with [boot2docker](https://github.com/docker/docker/issues/6396). A work around
is to ssh to the boot2docker image and then run the container directly from there.
Your home directory will be available as /Users within the container

    boot2docker ssh -A
    docker run -it --rm -v /Users:/Users -v $(readlink -f $SSH_AUTH_SOCK):/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent ubuntu /bin/bash

Ubuntu systems do not have this problem, so using vagrant is the current solution
in place

    vagrant up
    vagrant ssh -c sudo -E su -c /vagrant/packages/build_scripts/build-all.sh


## Creating the apt mirror

    nemesis bootstrap ${stack_name}
    nemesis-ops package init ${stack_name}
    nemesis-ops puppet build ${stack_name}
    nemesis-ops package upload ${stack_name}


## Adding a specific package

    nemesis-ops package add ${stack_name} path/to/*.deb


## Removing a specific package

    nemesis-ops package remove ${stack_name} path/to/*.deb


## Building the nemesis-puppet package

    nemesis-ops puppet build ${stack_name}


## Building an AMI
Run the following commands to generate an AMI in the region specified above.
Passing in a list of regions stores the AMI in the first region in the list and
copies it to the other regions once the build is complete.

    nemesis-ops ami build ${stack_name} \
      --tag <tag> \
      --regions=<list of regions> \
      --ami <existing ami id>

To just generate the ami template output run the following, note: if the file
path in not passed in then the template will just be printed to stdout

    nemesis-ops ami gen \
      --tag <tag> \
      --regions=<list of regions> \
      --ami <existing ami id> \
      /path/desired-output-file.json


## License
---
Except as otherwise noted this software is licensed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
