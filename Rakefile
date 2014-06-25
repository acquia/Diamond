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

  aptly_base_cmd = "aptly --config=#{$base_path}/packages/aptly.conf"
  s3 = Nemesis::Aws::Sdk::S3.new
  repo = s3.buckets[DEV_BUCKET]
  cache = $base_path + 'packages/cache'

  # Hello cascade
  Dir.chdir(cache) do |d|
    # Download all packages from s3 and write them to disk if needed
    repo.objects.each do |obj|
      path = cache + "#{obj.key}"
      unless File.exists? path
        Nemesis::Log.info("Downloading #{obj.key}")
        File.open(obj.key, 'wb') do |f|
          obj.read do |chunk|
            f.write(chunk)
          end
        end
      else
        Nemesis::Log.info("Using cached #{File.basename(path)}")
      end
    end

    begin
      aptly_command aptly_base_cmd, 'repo create --distribution=trusty --architectures=amd64 nemesis-testing'
      aptly_command aptly_base_cmd, 'repo add nemesis-testing .'
      # @todo start using signing key
      aptly_command aptly_base_cmd, 'publish repo --skip-signing=true nemesis-testing'
      s3_upload_repo(DEV_REPO)
    ensure
      #%w(db pool public).each{|dir| FileUtils.rm_r(dir)}
    end
  end
end


# From http://docs.aws.amazon.com/cli/latest/reference/s3/sync.html
#  "A local file will require uploading if the size of the local file is different
#  than the size of the s3 object, the last modified time of the local file is
#  newer than the last modified time of the s3 object, or the local file does
#  not exist under the specified bucket and prefix"
def s3_upload_repo(bucket)
  s3 = Nemesis::Aws::Sdk::S3.new
  repo = s3.buckets[bucket]
  unless repo.exists?
    repo = s3.buckets.create(bucket, :acl => :public_read)
    repo.configure_website
  end
  path = $base_path + 'packages/cache/public'
  Dir.glob(path.to_s + '/**/*').each do |file|
    next if File.directory? file
    file_path = Pathname.new(file)
    key = file_path.relative_path_from(path)
    object = repo.objects[key]
    mtime = File.mtime(file_path)
    size = File.size(file_path)
    if !object.exists? || mtime != object.last_modified || size != object.content_length
      Nemesis::Log.info("Uploading #{file_path.relative_path_from(path)}")
      object.write(file_path, :acl => :public_read)
    end
  end
end

def aptly_command(base, cmd)
  command = base + ' ' + cmd
  Nemesis::Log.info(command)
  puts `#{command}`
end

# todo add prod argument and bucket name
task :upload_package, [:package] do |task, args|
end
