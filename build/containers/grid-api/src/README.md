# Grid API

[![Build Status](https://magnum.travis-ci.com/acquia/grid-api.svg?token=V11Dcpsz9xGpCipC8pBD&branch=master)](https://magnum.travis-ci.com/acquia/grid-api)

API and CLI application for managing application on the Acquia Grid

## Usage
For complete usage for managing an application on the Acquia Grid please refer to the Grid CLI help

	grid-cli --help


## Manifest files
A example manifest file can be created using

	grid-cli bootstrap -f grid.yaml


## Development
To set started developing or building the Grid API you will need to have either a GO lang
environment setup or you can you the Docker development environment we have provided. To get started
with the Docker development environment run the following commands

	make build-container
	make run-container

This will build the Docker development image and drop you into the container with the source code
mounted at the path

	/usr/share/go/src/github.com/acquia/grid-api

You will be able to edit locally using your favorite editor and then compile within the Docker
container. To compile simple run

	make

The binaries will be placed on the GOPATH for you at

	/usr/share/go/bin/{grid-api, grid-cli}

## Further reading
[Architecture Overview and Gotchas](docs/arch.md)


## License
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
