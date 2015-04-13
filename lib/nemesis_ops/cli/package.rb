# Copyright 2014 Acquia, Inc.
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

module NemesisOps::Cli
  class Package < Thor
    include NemesisOps::Common

    desc 'init STACK_NAME', 'Build the Apt repo'
    method_option :gpg_key, :type => :string, :default => NemesisOps::GPG_KEY, :desc => 'The GPG key used to sign the packages'
    def init(stack_name)
      build_repo(stack_name, options[:gpg_key])
    end

    desc 'upload STACK_NAME', 'Upload the Apt repo for the given stack'
    def upload(stack_name)
      package_repo = get_bucket_from_stack(stack_name, 'repo')
      s3_upload(package_repo, NemesisOps::BASE_PATH + 'packages/repo/public', :public_read)
    end

    desc 'add STACK_NAME PACKAGE', "Add a package to the stack's package listing"
    method_option :gpg_key, :type => :string, :default => NemesisOps::GPG_KEY, :desc => 'The GPG key used to sign the packages'
    def add(stack_name, package)
      add_package(stack_name, package, gpg_key)
    end

    desc 'sync STACK_NAME', 'Get the packages from the repo and add them to your cache directory'
    def sync(stack_name)
      get_repo(stack_name)
    end

    desc 'remove STACK_NAME PACKAGE', 'Remove package from aptly and s3'
    method_option :gpg_key, :type => :string, :default => NemesisOps::GPG_KEY, :desc => 'The GPG key used to sign the packages'
    def remove(stack_name, package)
      remove_package(stack_name, package, options[:gpg_key])
    end

    desc 'replace STACK_NAME PACKAGE_PATH', 'Re-add a package to aptly'
    method_option :gpg_key, :type => :string, :default => NemesisOps::GPG_KEY, :desc => 'The GPG key used to sign the packages'
    def replace(stack_name, package_path)
      package_name = File.basename(package_path)[/[-a-zA-Z]+/]
      remove_package(stack_name, package_name, options[:gpg_key])
      add_package(stack_name, package_path, options[:gpg_key])
    end
  end
end
