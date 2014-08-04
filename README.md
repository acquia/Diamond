# Nemesis Package Manager
APT Packages manager and Puppet manifests used with Nemesis


## Dependencies
Dependencies needed to be available before working with the Nemesis Package Manager:

  * Setup GPG key for signing packages (Puppet Base:repos assumes key in use is 23406CA7)
  * Setup AWS credentials and ssh keys
  * Install Vagrant
  * Install Go (configure $GOPATH according to docs)
    * Mac: brew install go
  * Install Aptly package mirror tool

      go get -u github.com/mattn/gom
      mkdir -p $GOPATH/src/github.com/smira/aptly
      git clone https://github.com/smira/aptly $GOPATH/src/github.com/smira/aptly
      cd $GOPATH/src/github.com/smira/aptly
      gom -production install
      gom build -o $GOPATH/bin/aptly

    * Add $GOPATH/bin to your $PATH
  * Nemesis gem installed or available in RUBYPATH
    *  export RUBYLIB=$RUBYLIB:/sandbox/nemesis/lib

## Setup

    git submodule update --init --recursive
    bundle install


## Building the packages

    vagrant up
    cd /vagrant/packages/build_scripts
    for $x in *.sh; do bash ${x} ; done


## Creating the apt mirror

    export stack_name='nemesis'
    nemesis bootstrap ${stack_name}
    nemesis-ops package sync_cache_packages ${stack_name}
    nemesis-ops package build_repo ${stack_name}


## Updating a specific package

    nemesis-ops package upload nemesis packages/cache/*.deb

