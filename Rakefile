require 'fileutils'
require 'multi_json'
require 'oj'
require 'tmpdir'

require 'nemesis'

DEV_BUCKET = 'acquia-dev-nemesis-packages'
DEV_REPO = 'acquia-dev-nemesis-repo'
$base_path = Pathname.new(File.dirname(File.absolute_path(__FILE__)))

# todo add prod argument and bucket name
task :build_repo do
  result = `which aptly`
  if result.empty?
    puts "You need to install aptly"
    exit 1
  end

  s3 = Nemesis::Aws::Sdk::S3.new
  bucket = s3.buckets[DEV_BUCKET]
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
    s3_upload_repo(DEV_REPO)
  end
end


def s3_upload_repo(bucket)
  s3 = Nemesis::Aws::Sdk::S3.new
  repo = s3.buckets[bucket]
  unless repo.exists?
    repo = s3.buckets.create(bucket, :acl => :public_read)
    repo.configure_website
  end
  path = $base_path + 'packages/repo/public'
  Dir.glob(path.to_s + '/**/*').each do |file|
    next if File.directory? file
    file_path = Pathname.new(file)
    key = file_path.relative_path_from(path)
    object = repo.objects[key]
    if needs_upload?(file_path, object)
      Nemesis::Log.info("Uploading #{file_path.relative_path_from(path)}")
      object.write(file_path, :acl => :public_read)
    end
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
task :upload_package, [:package] do |task, args|
  s3 = Nemesis::Aws::Sdk::S3.new
  repo = s3.buckets[DEV_BUCKET]
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
