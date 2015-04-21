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

require 'date'
require 'fileutils'
require 'multi_json'
require 'oj'
require 'pathname'
require 'tmpdir'
require 'zlib'

# @todo: remove nemesis dependency
require 'nemesis'

module NemesisOps
  module Common
    CACHE_DIR = NemesisOps::PKG_DIR.join('cache')
    REPO_DIR = NemesisOps::PKG_DIR.join('repo')

    def s3_upload(bucket, path, acl = :private)
      s3 = Nemesis::Aws::Sdk::S3.new
      repo = s3.buckets[bucket]
      if path.directory?
        Dir.glob(path.to_s + '/**/*').each do |file|
          next if File.directory? file
          NemesisOps::EXCLUDE_PATTERNS.each do |pattern|
            next if file =~ pattern
          end
          file_path = Pathname.new(file)
          key = file_path.relative_path_from(path)
          object = repo.objects[key]
          Nemesis::Log.info("Syncing #{file_path.relative_path_from(path)}")
          s3_upload_file(file_path, object, acl)
        end
      else
        key = path.basename
        object = repo.objects[key]
        Nemesis::Log.info("Syncing #{path.basename}")
        s3_upload_file(path, object, acl)
      end
    end

    def s3_upload_file(file, object, acl)
      if needs_update?(file, object)
        object.write(file, :acl => acl)
      end
    end

    # From http://docs.aws.amazon.com/cli/latest/reference/s3/sync.html
    #  "A local file will require uploading if the size of the local file is different
    #  than the size of the s3 object, the last modified time of the local file is
    #  newer than the last modified time of the s3 object, or the local file does
    #  not exist under the specified bucket and prefix"
    def needs_update?(file, object)
      return true if !object.exists? || !File.exists?(file)

      # Compare sizes first since md5 is actually unreliable
      size = File.size(file)
      size_diff = size != object.content_length
      return size_diff if size_diff == true
      etag = object.etag.gsub('"', '')
      unless etag.match('-')
        md5 = Digest::MD5.file(file).hexdigest
        etag != md5
      else
        size_diff
      end
    end

    def get_bucket_from_stack(stack, logical_name)
      cf = Nemesis::Aws::Sdk::CloudFormation.new
      cf.stacks[stack].resources[logical_name].physical_resource_id
    end

    def bootstrap
      FileUtils.mkdir_p([CACHE_DIR, REPO_DIR])
    end

    def aptly(cmd)
      bootstrap
      command = "aptly --config=#{NemesisOps::PKG_DIR}/aptly.conf #{cmd}"
      Nemesis::Log.info(command)
      `#{command}`
    end

    def get_repo(stack)
      FileUtils.mkdir_p(CACHE_DIR)
      s3 = Nemesis::Aws::Sdk::S3.new
      packages = get_bucket_from_stack(stack, 'repo')
      repo = s3.buckets[packages]
      debs = repo.objects.select { |o| o.key =~ /\.deb/ }
      debs.each do |deb|
        package = File.basename(deb.key)
        cache_path = CACHE_DIR.join(package)
        if needs_update?(cache_path, deb)
          Nemesis::Log.info("Downloading #{package}")
          File.open(cache_path, 'wb') do |file|
            deb.read do |chunk|
              file.write(chunk)
            end
          end
        end
      end
    end

    def build_repo(stack, gpg_key)
      bootstrap
      result = `which aptly`
      if result.empty?
        puts 'You need to install aptly'
        exit 1
      end

      dist_dir = NemesisOps::BASE_PATH.join('dist')

      # Copy the dist_dir contents over to the CACHE_DIR
      FileUtils.cp_r(Dir.glob(dist_dir.join('*')), CACHE_DIR)

      # Get the contents of the existing repo
      get_repo(stack)

      # Build the repo w/ Aptly
      Dir.chdir(REPO_DIR) do |d|
        unless File.directory?('db') && File.directory?('pool')
          aptly "repo create --distribution=#{NemesisOps::DEFAULT_OS} --architectures=amd64 nemesis-testing"
        end
        aptly "repo add --force-replace=true nemesis-testing #{CACHE_DIR}"
        unless File.directory?('public')
          aptly "publish repo --gpg-key=#{gpg_key} nemesis-testing"
        else
          aptly "publish update --gpg-key=#{gpg_key} #{NemesisOps::DEFAULT_OS}"
        end
      end

      # Add the GPG key to the repo
      key_file = REPO_DIR.join('public', 'pubkey.gpg')
      `gpg --armor --yes --output #{key_file} --export #{gpg_key}`
    end

    def add_package(stack_name, package_path, gpg_key)
      path = Pathname.new(File.absolute_path(package_path))
      unless File.exists? path
        Nemesis::Log.error("You must specifiy a valid file: #{path} does not exist")
        exit 1
      end
      cache_path = NemesisOps::Common::CACHE_DIR
      FileUtils.cp(path, cache_path) unless File.exists?(cache_path + File.basename(path))
      build_repo(stack_name, options[:gpg_key])
    end

    def remove_package(stack, package, gpg_key)
      s3 = Nemesis::Aws::Sdk::S3.new
      repo = s3.buckets[get_bucket_from_stack(stack, 'repo')]

      # Find deletable devel packages in the bucket
      s3_del_candidates = repo.objects.select { |p| p.key =~ /#{package}_((\d+\.?)+).*\.deb/ }

      # Delete packages from bucket
      s3_del_candidates.map(&:delete)

      # Cleanup aptly's pool. Packages which are not referenced in any repo are deleted.
      if File.exists? REPO_DIR
        Dir.chdir(REPO_DIR) do |d|
          # Remove package from aptly
          aptly "repo remove nemesis-testing #{package}"
          aptly 'db cleanup'
          aptly "publish update --gpg-key=#{gpg_key} #{NemesisOps::DEFAULT_OS}"
        end
      else
        Nemesis::Log.error('Unable to clean Aptly repository. Have you run nemesis-ops package init?')
        exit 1
      end

      # Find packages and delete from local-cache.
      puppet_del_packages = Dir.glob(NemesisOps::Common::CACHE_DIR.join('*.deb')).select { |p| File.basename(p) =~ /#{package}_((\d+\.?)+).*\.deb/ }
      FileUtils.rm(puppet_del_packages)
    end
  end
end
