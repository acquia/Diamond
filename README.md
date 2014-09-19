# Nemesis Package Manager
APT Packages manager and Puppet manifests used with Nemesis


## Dependencies
Dependencies needed to be installed and configured before working with the Nemesis Package Manager:

  * Setup GPG key for signing packages (Puppet Base:repos assumes key in use is 23406CA7)
    
    * Mac: brew install gpg
    
    ````
    gpg --gen-key
    gpg --keyserver pgp.mit.edu --send-keys <KEY ID>
    ````
    
    * Note: If you needed to generate a new key, you need to change nemesis-ops script for now to use your personal key
    
  * Setup AWS credentials and ssh keys
  * Install Vagrant
  * Install Go (configure $GOPATH according to docs)
    * Mac: brew install go
    * Mac: brew install mercurial
  * Install Aptly package mirror tool

    ````
    echo "export GOPATH=$HOME/go" >> ~/.profile
    source ~/.profile
    go get -u github.com/mattn/gom
    mkdir -p $GOPATH/src/github.com/smira/aptly
    git clone https://github.com/smira/aptly $GOPATH/src/github.com/smira/aptly
    cd $GOPATH/src/github.com/smira/aptly
    gom -production install
    gom build -o $GOPATH/bin/aptly
    ````

    * Add $GOPATH/bin to your $PATH
  * Nemesis gem installed or available in RUBYPATH
    *  export RUBYLIB=$RUBYLIB:/sandbox/nemesis/lib

## Setup

Go back to the nemesis-puppet folder

    bundle install


## Building the packages

    vagrant up
    vagrant ssh
    sudo -E su
    cd /vagrant/packages/build_scripts
    for x in *.sh; do bash ${x} ; done
    exit
    exit


## Creating the apt mirror

    export stack_name='nemesis'
    nemesis bootstrap ${stack_name}
    ./nemesis-ops package construct-repo ${stack_name}
    ./nemesis-ops package upload-repo ${stack_name}


## Updating a specific package

    ./nemesis-ops package add ${stack_name} packages/cache/*.deb


## Adding a new third-party module to Puppet
Edit the Puppetfile to point to the right module path

    librarian-puppet install


## Building the nemesis-puppet package

    ./nemesis-ops puppet build ${stack_name}


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
