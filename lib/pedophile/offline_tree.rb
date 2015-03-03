require 'yaml'
require 'pathname'

module Pedophile
  class OfflineTree
    TMP_STRUCTURE_PATH = File.absolute_path(File.join(Wget::TMP_PATH, "files.yaml"))
    FIX_RELATIVE_PATH = true

    def initialize(downloader)
      @downloader = downloader
      @files = Array.new
    end

    attr_reader :downloader, :files

    # Desctructive part
    def after_process
      load_processed
      remove_bad_suffix
      rename_files
    end

    def path
      @path ||= self.downloader.wget.offline_path
      @path
    end

    def analyze
      # because I don't want to read all wget options...
      glob_path = "#{path}/**/**"
      puts "offline path #{path.to_s.cyan}"

      Dir.glob(glob_path) do |item|
        next if item == '.' or item == '..' or File.directory?(item)

        puts "analyze file #{item.to_s.yellow}"

        h = Hash.new
        h[:path] = item

        mime = `file --mime #{item}`
        if mime =~ /(\w+\/\w+);/
          mime = $1
        else
          mime = nil
        end

        h[:mime] = mime

        if mime == 'text/html' or mime == 'text/plain'
          h[:inside] = analyze_file(item)
        end

        @files << h
      end

      save_analyzed
    end

    def save_analyzed
      f = File.new(TMP_STRUCTURE_PATH, "w")
      f.puts @files.to_yaml
      f.close
    end

    def load_analyzed
      @files = YAML.load_file(TMP_STRUCTURE_PATH)
    end

    def analyze_file(file)
      s = File.read(file)

      possible_paths_regexp = /"([^"]+)"/
      possible_paths = s.scan(possible_paths_regexp).flatten.uniq

      possible_paths_regexp = /'([^']+)'/
      possible_paths += s.scan(possible_paths_regexp).flatten.uniq

      relative_file_path = File.dirname(file)

      paths = Array.new
      possible_paths.each do |pp|
        if is_path_ok?(pp)
          h = Hash.new
          f = File.join(relative_file_path, pp)
          h[:exists] = File.exists?(f)
          h[:is_file] = File.file?(f)
          h[:path] = pp

          paths << h if should_add_path?(h)
        end
      end

      paths
    end

    # TODO  - check if this string is correct unix path
    def is_path_ok?(pp)
      # pp =~ /\A(?:[0-9a-zA-Z\_\-]+\/?)+\z/
      pp.size < 200
    end

    # TODO
    def should_add_path?(h)
      return true
      #return h[:is_file]
    end

    def base_path
      @base_path ||= self.downloader.wget.offline_path
      @base_path
    end

    # PROCESSING
    def process_bad_suffix
      @files.each do |f|
        old_file = f[:path]
        new_file = old_file.gsub(/\?body=1/, '')

        if not new_file == old_file
          process_rename_file(old_file, new_file)
        end
      end

      process_massive_gsub("%3Fbody=1", "", false)
    end

    def process_bad_filenames
      @files.each do |f|
        old_file = f[:path]
        new_file = old_file.gsub(/[^0-9A-Za-z.\-\/:]/, '_')

        if not new_file == old_file
          process_rename_file(old_file, new_file)
        end
      end

    end

    def process_rename_file(old_file_path, new_file_path)
      puts "rename from #{old_file_path.to_s.blue} to #{new_file_path.to_s.green}"

      # clone to not allow modify of @files
      old_file = old_file_path.clone
      new_file = new_file_path.clone
      # this will be with full path
      old_file_with_path = old_file_path.clone

      old_file.gsub!(base_path, '')
      new_file.gsub!(base_path, '')

      # ignore slashes
      old_file.gsub!(/^\//, '')
      new_file.gsub!(/^\//, '')

      # 1. rename 1 file
      new_file_path = old_file_with_path.gsub(old_file, new_file)
      File.rename(old_file_with_path, new_file_path)

      # 2. rename in @files
      @files.each do |f|
        puts "*"*100, f[:path], old_file_with_path
        if f[:path] == old_file_with_path
          f[:path] = new_file_path
        end
      end

      # 3. gsub all files
      # gsub files after renaming
      process_massive_gsub(old_file, new_file, true)

      puts "RENAMED #{old_file.to_s.blue} to #{new_file.to_s.green}"
    end

    def process_massive_gsub(from, to, check_paths = false)
      puts "massive gsub #{from.to_s.blue} to #{to.to_s.green}"

      @files.each do |f|
        # must be proper mime before, so not needed to check
        if f[:inside]
          file_path = f[:path].clone

          puts " open #{file_path.to_s.red}"

          # relative path fix
          if check_paths and FIX_RELATIVE_PATH
            relative_file_path = File.dirname(file_path).gsub(self.path, "")
            relative_file_path.gsub!(/^\//, '')

            first = Pathname.new(relative_file_path)
            second = Pathname.new(to)
            to = second.relative_path_from(first)
          end

          exists = File.exists?(file_path)
          if exists
            j = File.open(file_path)
            s = j.read
            j.close

            # TODO check relative paths

            s.gsub!(from, to)

            j = File.open(file_path, "w")
            j.puts(s)
            j.close

            f[:inside].each do |fi|
              fi[:path].gsub!(from, to)
            end

            puts " done #{file_path.to_s.red}"
          else
            raise "file #{file_path} not found"
          end
        end
      end
    end

  end
end