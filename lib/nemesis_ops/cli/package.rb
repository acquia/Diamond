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
    include NemesisOps::Cli::Common

    desc 'upload STACK PACKAGE', "Add a package to the stack's package listing"
    method_option :gpg_key, :type => :string, :default => NemesisOps::GPG_KEY, :desc => 'The GPG key used to sign the packages'
    def upload(stack_name, package)
      path = Pathname.new(File.absolute_path(package))
      unless File.exists? path
        Nemesis::Log.error("You must specifiy a valid file: #{path} does not exist")
        exit 1
      end
      cache_path = NemesisOps::Cli::Common::CACHE_DIR + 'cache'
      FileUtils.cp(path, cache_path) unless File.exists?(cache_path + File.basename(path))
      build_repo(stack_name, options[:gpg_key])
    end

    desc 'sync-repo STACK', 'Get the packages from the repo and add them to your cache directory'
    def sync_repo(stack)
      get_repo(stack)
    end

    desc 'construct-repo STACK', 'Build the Apt repo'
    method_option :gpg_key, :type => :string, :default => NemesisOps::GPG_KEY, :desc => 'The GPG key used to sign the packages'
    def construct_repo(stack)
      build_repo(stack, options[:gpg_key])
    end

    desc 'upload-repo STACK', 'Upload the Apt repo for the given stack'
    def upload_repo(stack)
      package_repo = get_bucket_from_stack(stack, 'repo')
      s3_upload(package_repo, NemesisOps::BASE_PATH + 'packages/repo/public', :public_read)
    end
  end
end
