#!/usr/bin/env ruby

# This script is responsible for compressing and rotating previously-rotated
# logs that were not compressed. For example, the python log rotation facility
# does not have a convenient way to compress, so we hijack the process and
# compress the already-rotated logs. Since we change the name of the file, we
# block python's ability to delete the files. Therefore we also need to delete
# files after a certain age.

class NemesisRotate < NemesisServer::Hook
  # Creates a new NemesisRotate object.
  def initialize
    super
    @events = NemesisServer::HookManager::EVENT_REPEAT
    @version = '0.0.1'
    @interval = 60 * 24 # Run once per day.
  end

  # Locates files that have not yet been compressed.
  #
  # @param dir [String] the directory path to search
  # @param log_pattern [Regex] a pattern to use when locating the correct files
  # @return [Array] the found filepaths
  def find_uncompressed_files(dir, log_pattern)
    uncompressed = []
    if Dir.exists? dir
      Dir.glob(File.join(dir, '*')).each do |filepath|
        uncompressed << filepath if filepath.match(log_pattern)
      end
    end
    uncompressed
  end

  # Locates files that are older than a specified age
  #
  # @param dir [String] the directory path to search
  # @param type [String] a file glob string, e.g. 'archive*'
  # @param age [Integer] the file age in seconds that should be located
  # @return [Array] the found filepaths
  def find_outdated_files(dir, type, age)
    outdated = []
    if Dir.exists? dir
      Dir.glob(File.join(dir, type)).each do |filepath|
        mtime = File.stat(filepath).mtime.to_i
        outdated << filepath if (Time.now.to_i - mtime) > age
      end
    end
    outdated
  end

  # Compresses a list of file paths
  #
  # @param files [Array] a list of fully-qualified file paths to compress
  # @param dir [String] the directory path of the files as a safeguard
  def compress_files(files, dir)
    files.each do |filepath|
      if filepath.start_with?(dir)
        result = `/bin/gzip #{filepath} && echo "success"`
        @log.info "Compressing #{filepath}: #{result}"
      else
        @log.error "Refusing to compress #{filepath}"
      end
    end
  end

  # Removes a list of file paths
  #
  # @param files [Array] a list of fully-qualified file paths to remove
  # @param dir [String] the directory path of the files as a safeguard
  def remove_files(files, dir)
    files.each do |filepath|
      if filepath.start_with?(dir)
        result = File.delete(filepath)
        @log.info "Removing #{filepath}: #{result}"
      else
        @log.error "Refusing to delete #{filepath}"
      end
    end
  end

  # Implements NemesisServer::Hooks::execute.
  def execute
    # Handle diamond log files.
    from_logdir = '/mnt/log/diamond'
    max_age = 60 * 60 * 24 * 3
    log_pattern = /\.log\.[\d]{4}-[\d]{2}-[\d]{2}$/

    # Remove outdated files.
    diamond_files_to_remove = find_outdated_files(from_logdir, '*.log.*', max_age)
    remove_files(diamond_files_to_remove, from_logdir)

    # Compress any files that have not previously been compressed
    diamond_files_to_compress = find_uncompressed_files(from_logdir, log_pattern)
    compress_files(diamond_files_to_compress, from_logdir)

    # Handle carbon-daemon log files.
    from_logdir = '/mnt/log/carbon-daemon'
    max_age = 60 * 60 * 24 * 3
    log_pattern = /\.log\.[\d]{4}_[\d]{1,2}_[\d]{1,2}$/

    # Remove outdated files.
    carbon_files_to_remove = find_outdated_files(from_logdir, '*.log.*', max_age)
    remove_files(carbon_files_to_remove, from_logdir)

    # Compress any files that have not previously been compressed
    carbon_files_to_compress = find_uncompressed_files(from_logdir, log_pattern)
    compress_files(carbon_files_to_compress, from_logdir)

    0
  end
end

NemesisServer::HookManager.register NemesisRotate.new
