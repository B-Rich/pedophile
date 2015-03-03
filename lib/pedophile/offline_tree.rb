require 'yaml'

module Pedophile
  class OfflineTree
    TMP_STRUCTURE_PATH = File.absolute_path(File.join(Wget::TMP_PATH, "files.yaml"))

    def initialize(downloader)
      @downloader = downloader
      @files = Array.new
    end

    attr_reader :downloader, :path

    # Desctructive part
    def after_process
      load_processed
      remove_bad_suffix
      rename_files
    end

    def process
      # because I don't want to read all wget options...
      @path = self.downloader.wget.offline_path
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
          h[:inside] = process_file(item)
        end

        @files << h
      end

      save_processed
    end

    def save_processed
      f = File.new(TMP_STRUCTURE_PATH, "w")
      f.puts @files.to_yaml
      f.close
    end

    def load_processed
      @files = YAML.load_file(TMP_STRUCTURE_PATH)
    end

    def process_file(file)
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

    def remove_bad_suffix
      @files.each do |f|
        old_file = f[:path]
        new_file = old_file.gsub(/\?body=1/, '')

        if not new_file == old_file
          rename_file(old_file, new_file)
        end
      end

      perform_massive_html_change("%3Fbody=1", "")
    end

    def rename_files
      @files.each do |f|
        old_file = f[:path]
        new_file = old_file.gsub(/[^0-9A-Za-z.\-\/:]/, '_')

        if not new_file == old_file
          rename_file(old_file, new_file)
        end
      end
    end

    def rename_file(old_file, new_file)
      # old_file - starting file name
      # new_file - rename to it
      base_path = self.downloader.wget.offline_path

      old_file_path = old_file.clone

      old_file.gsub!(base_path, '')
      new_file.gsub!(base_path, '')

      # ignore slashes
      old_file.gsub!(/^\//, '')
      new_file.gsub!(/^\//, '')

      #puts base_path, old_file_path, old_file, new_file

      perform_massive_html_change(old_file, new_file)

      # to get along with paths
      new_file_path = old_file_path.gsub(old_file, new_file)
      File.rename(old_file_path, new_file_path)
      # rename in tree
      @files.each do |f|
        #f[:path] = new_file_path if f[:path] == old_file_path
        f[:path].gsub!(old_file, new_file)
      end

      puts "renamed '#{old_file} to #{new_file}"
    end

    def perform_massive_html_change(from, to)
      puts "file content change string #{from.to_s.green} to #{to.to_s.blue}"

      # puts @files.collect{|f| f[:path]}.join("\n")


      @files.each do |f|
        # must be proper mime before, so its ok condition
        if f[:inside]
          puts " open #{f[:path].to_s.red}"
          exists = File.exists?(f[:path])

          if exists
            j = File.open(f[:path])
            s = j.read
            j.close

            s.gsub!(from, to)

            #j = File.open(f[:path], "w")
            #j.puts(s)
            #j.close

            f[:inside].each do |fi|
              fi[:path].gsub!(from, to)
            end

            puts " done #{f[:path].to_s.red}"
          end
        end
      end
    end

    # TODO  - check if this string is correct unix path
    def is_path_ok?(pp)
      # pp =~ /\A(?:[0-9a-zA-Z\_\-]+\/?)+\z/
      pp.size < 200
    end

    # TODO
    def should_add_path?(h)
      return h[:is_file]
    end

  end
end