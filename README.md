# Nemesis Package Manager
[![Build Status](https://magnum.travis-ci.com/acquia/nemesis-puppet.svg?token=fuZxkY8h1TVDnxYTXZSB&branch=master)](https://magnum.travis-ci.com/acquia/nemesis-puppet)  
APT Packages manager and Puppet manifests used with Nemesis


## Dependencies
Dependencies needed to be installed and configured before working with the Nemesis Package Manager:

  * Setup GPG key for signing packages. If you generate a new key, you need to use the `nemesis-ops --gpg-key` flag to use that generated key. If no key is provided then the default key used is 23406CA7.

    * Mac: brew install gpg

    ````
    gpg --gen-key
    gpg --keyserver pgp.mit.edu --send-keys <KEY ID>
    ````

  * Setup AWS credentials and ssh keys
  * Install Vagrant
    * https://www.vagrantup.com/downloads.html
  * Install dependencies
    -  aptly gnu-tar
        * Mac: brew install aptly gnu-tar
  * Nemesis gem installed or available in RUBYPATH
    *  export RUBYLIB=$RUBYLIB:/sandbox/nemesis/lib
  * Packer
    * Mac: brew tap homebrew/binary && brew install packer

## Setup

Go back to the nemesis-puppet folder

    bundle install
    export stack_name='nemesis'


## Building the packages
The package build system uses Vagrant and Docker as its main components for
building all packages. Vagrant launches a base ubuntu host and Docker
containers are used to isolate each script. The resulting package from each
script is left in the ./dist directory.

    vagrant up
    vagrant ssh -c sudo -E su -c /vagrant/packages/build_scripts/build-all.sh


## Building the nemesis-puppet package

    nemesis-ops puppet build ${stack_name}


## Creating the apt mirror

    nemesis bootstrap ${stack_name}
    nemesis-ops package construct-repo ${stack_name}
    nemesis-ops package upload-repo ${stack_name}


## Updating a specific package

    nemesis-ops package add ${stack_name} packages/cache/*.deb

## Building an AMI
Run the following commands to generate an AMI in the region specified above.
Passing in a list of regions stores the AMI in the first region in the list and
copies it to the other regions once the build is complete.

    nemesis-ops ami template --repo ${stack_name} \
      --tag ${tag} \
      --regions=<list_of_regions> 
      <path_to_yaml_file> > /tmp/ami.json

    packer build /tmp/ami.json


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
