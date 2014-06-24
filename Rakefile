require 'fileutils'
require 'multi_json'
require 'oj'
require 'tmpdir'

require 'nemesis'

DEV_BUCKET = 'acquia-dev-nemesis-packages'
DEV_REPO = 'acquia-dev-nemesis-repo'

# todo add prod argument and bucket name
task :build_repo do
  result = `which aptly`
  if result.empty?
    puts "You need to install aptly"
    exit 1
  end

  base_path = File.dirname(File.absolute_path(__FILE__))
  aptly_base_cmd = "aptly --config=#{base_path}/packages/aptly.conf"
  s3 = Nemesis::Aws::Sdk::S3.new
  repo = s3.buckets[DEV_BUCKET]
  cache = base_path + '/packages/cache'

  # Hello cascade
  Dir.chdir(cache) do |d|
    # Download all packages from s3 and write them to disk if needed
    repo.objects.each do |obj|
      path = cache + "/#{obj.key}"
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
    ensure
      #%w(db pool public).each{|dir| FileUtils.rm_r(dir)}
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
