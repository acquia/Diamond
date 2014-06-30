require 'fileutils'
require 'multi_json'
require 'oj'
require 'tmpdir'
require 'rake'
require 'zlib'

require 'nemesis'

# File patterns to always exclude from S3 syncs
EXCLUDE_PATTERNS = [
  /\.s[a-w][a-z]$/
]

$base_path = Pathname.new(File.dirname(File.absolute_path(__FILE__)))

# todo add prod argument and bucket name
desc "Sync and redeploy the apt repository"
task :build_repo do
  result = `which aptly`
  if result.empty?
    puts "You need to install aptly"
    exit 1
  end

  s3 = Nemesis::Aws::Sdk::S3.new
  cf = Nemesis::Aws::Sdk::CloudFormation.new
  packages = cf.buckets['nemesis'].resources['packages'].physical_resource_id
  repo = cf.buckets['nemesis'].resources['repo'].physical_resource_id
  bucket = s3.buckets[packages]
  cache = $base_path + 'packages/cache'
  repo = $base_path + 'packages/repo'

  # Hello cascade
  Dir.chdir(repo) do |d|
    # Download all packages from s3 and write them to disk if needed
    bucket.objects.each do |obj|
      path = cache + "#{obj.key}"
      unless File.exists?(path)
        Nemesis::Log.info("Downloading #{obj.key}")
        File.open(cache + obj.key, 'wb') do |f|
          obj.read do |chunk|
            f.write(chunk)
          end
        end
      else
        Nemesis::Log.info("Using cached #{File.basename(path)}")
      end
    end

    unless File.directory?('db') && File.directory?('pool')
      aptly 'repo create --distribution=trusty --architectures=amd64 nemesis-testing'
    end
    aptly "repo add nemesis-testing #{cache}"
    unless File.directory?('public')
      aptly 'publish repo --gpg-key=23406CA7 nemesis-testing'
    else
      aptly 'publish update --gpg-key=23406CA7 trusty'
    end
    s3_upload(repo, $base_path + 'packages/repo/public', :public_read)
  end
end


def s3_upload(bucket, path, acl = :private)
  s3 = Nemesis::Aws::Sdk::S3.new
  repo = s3.buckets[bucket]
  unless repo.exists?
    repo = s3.buckets.create(bucket, :acl => acl)
  end
  if path.directory?
    Dir.glob(path.to_s + '/**/*').each do |file|
      next if File.directory? file
      EXCLUDE_PATTERNS.each do |pattern|
        next if file =~ pattern
      end
      file_path = Pathname.new(file)
      key = file_path.relative_path_from(path)
      object = repo.objects[key]
      Nemesis::Log.info("Uploading #{file.relative_path_from(path)}")
      s3_upload_file(file_path, object, acl)
    end
  else
    key = path.basename
    object = repo.objects[key]
    Nemesis::Log.info("Uploading #{path.basename}")
    s3_upload_file(path, object, acl)
  end
end

def s3_upload_file(file, object, acl)
  if needs_upload?(file, object)
    object.write(file, :acl => acl)
  end
end

# From http://docs.aws.amazon.com/cli/latest/reference/s3/sync.html
#  "A local file will require uploading if the size of the local file is different
#  than the size of the s3 object, the last modified time of the local file is
#  newer than the last modified time of the s3 object, or the local file does
#  not exist under the specified bucket and prefix"
def needs_upload?(file, object)
  mtime = File.mtime(file)
  size = File.size(file)
  !object.exists? || mtime != object.last_modified || size != object.content_length
end

def aptly(cmd)
  base = "aptly --config=#{$base_path}/packages/aptly.conf"
  command = base + ' ' + cmd
  Nemesis::Log.info(command)
  puts `#{command}`
end

# todo add prod argument and bucket name
desc "Upload a single package to the packages S3 bucket"
task :upload_package, [:package] do |task, args|
  s3 = Nemesis::Aws::Sdk::S3.new
  repo = s3.buckets[DEV_PACKAGES]
  path = Pathname.new(File.absolute_path(args[:package]))
  unless File.exists? path
    Nemesis::Log.error("You must specifiy a valid file: #{path} does not exist")
    exit 1
  end
  cache_path = $base_path + 'packages/cache'
  FileUtils.cp(path, cache_path) unless File.exists?(cache_path)
  key = path.basename
  Nemesis::Log.info("Uploading #{key}")
  object = repo.objects[key]
  if needs_upload?(path, object)
    object.write(path)
    Nemesis::Log.info("Successfully uploaded #{key}")
  else
    Nemesis::Log.info("#{key} has already been uploaded!")
  end
end

namespace :puppet do
  desc "Update Puppet repo S3 mirror"
  task :upload do
    puppet = cf.buckets['nemesis'].resources['puppet'].physical_resource_id
    `tar --exclude=*.swp -cvzf puppet.tgz puppet/`
    s3_upload(puppet, $base_path + 'puppet.tgz')
  end
end
