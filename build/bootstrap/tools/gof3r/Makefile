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

# Download and build s3gof3r from https://github.com/rlmcpherson/s3gof3r
#
# Uses ENV parameters:
#   AWS_ACCESS_KEY_ID
#   AWS_SECRET_ACCESS_KEY
#
# docker run -d -e AWS_ACCESS_KEY_ID='' -e AWS_SECRET_ACCESS_KEY='' -v $(pwd):/dist "cp /dist s3://<bucket>/<s3_path>"

VERSION=0.5.0

all: build

# Download the gof3r binary
download:
	curl -sSL https://github.com/rlmcpherson/s3gof3r/releases/download/v${VERSION}/gof3r_${VERSION}_linux_amd64.tar.gz | tar -xz --strip 1 -C .

# Create the scratch container the application will run in
build: download
	docker build -t tools/gof3r -f Dockerfile.release .

clean:
	rm -rf gof3r
