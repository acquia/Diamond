# Nemesis Puppet
Puppet manifests and build scripts for Platform Health

## Getting Started
### Dependencies
There are a few different dependencies that need to be installed before you
will be able to work with the package repo:

  * Go
    * Mac: brew install go; configure $GOPATH according to docs
  * bundle install
  * Aptly

      ```
      go get -u github.com/mattn/gom
      mkdir -p $GOPATH/src/github.com/smira/aptly
      git clone https://github.com/smira/aptly $GOPATH/src/github.com/smira/aptly
      cd $GOPATH/src/github.com/smira/aptly
      gom -production install
      gom build -o $GOPATH/bin/aptly
      ```
    * Ensure that $GOPATH/bin is in your $PATH



## Package Repo
