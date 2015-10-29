# Copyright 2015 Acquia, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

applications=grid-api grid-cli

export PATH := $(abspath ./_vendor/bin):$(PATH)

GOM_GROUPS_FLAG="test"
GOM=$(if $(TRAVIS),$(HOME)/gopath/bin/gom,gom)

all: ${applications}

$(applications): deps gen
	$(GOM) build -o $(GOPATH)/bin/$@ $@/main.go

deps:
	$(GOM) -groups=$(GOM_GROUPS_FLAG) install

lint:
	$(GOM) exec go fmt ./...
	$(GOM) exec go vet -x ./...
	$(GOM) exec golint .

check: test
test: deps gen lint
	$(GOM) exec ginkgo -p -r -failOnPending -skipPackage="./thrift" -cover=true ./.

coverage:
	@for profile in $(shell find . -name "*.coverprofile" -not -path "_vendor/*"); do \
		dirname $$profile ; \
		go tool cover -func=$$profile ; \
		echo ; \
	done

gen:
	# Generate the Grid API and Aurora Thrift libraries.
	rm -rf ./thrift
	thrift -r --gen go:thrift_import=github.com/apache/thrift/lib/go/thrift,package_prefix=github.com/acquia/grid-api/ --out . resources/thrift/api.thrift
	rm -rf ./thrift/*-remote
	rm -rf _vendor/src/github.com/apache/aurora/api
	mkdir -p _vendor/src/github.com/apache/aurora/api
	thrift -r --gen go:thrift_import=github.com/apache/thrift/lib/go/thrift,package_prefix=github.com/apache/aurora/api/ --out _vendor/src/github.com/apache/aurora/ resources/aurora/thrift/api.thrift
	rm -rf _vendor/src/github.com/apache/aurora/api/*-remote

dist: test deb

deb:
	dpkg-buildpackage -uc -b -d -tc

docker-build:
	docker build -t grid-api .

docker-run:
	docker run --rm -v $(shell pwd)/:/usr/share/go/src/github.com/acquia/grid-api -it grid-api /bin/bash

test-container:
	docker run --rm -v $(shell pwd)/:/usr/share/go/src/github.com/acquia/grid-api -it grid-api /bin/bash -c "make test && make coverage"

release:
	docker run --rm -v $(shell pwd)/:/usr/share/go/src/github.com/acquia/grid-api -it grid-api /bin/bash -c "make dist && exit"

clean:
	rm -rf _vendor dist

.PHONY: all clean run deps test
