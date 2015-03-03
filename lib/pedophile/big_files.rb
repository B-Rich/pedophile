require 'fileutils'
require 'yaml'

module Pedophile
  class BigFiles
    USE_MIME = false
    TMP_STRUCTURE_PATH = File.absolute_path(File.join(Wget::TMP_PATH, "big_files.yaml"))

    def initialize(downloader)
      @downloader = downloader
      @files = Array.new
    end

    attr_reader :downloader, :full_path, :files, :files_path

    def offline_path
      self.downloader.wget.offline_path
    end

    def copy_folder(path)
      puts "copying big files path #{path.to_s.cyan}"
      FileUtils.cp_r(path, offline_path)
      puts "done copying path #{path.to_s.cyan}"
      big_files_path = path
    end

    def big_files_path=(path)
      @files_path = path
      @full_path = File.join(offline_path, path)
    end

    def analyze
      glob_path = "#{full_path}/**/**"
      puts "big files path #{full_path.to_s.cyan}"

      Dir.glob(glob_path) do |item|
        next if item == '.' or item == '..' or File.directory?(item)

        puts "analyze file #{item.to_s.yellow}"

        h = Hash.new
        h[:path] = item

        if USE_MIME
          mime = `file --mime #{item}`
          if mime =~ /(\w+\/\w+);/
            mime = $1
          else
            mime = nil
          end
          h[:mime] = mime
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

    def gsub_links
      files.each do |f|
        file_path = f[:path].clone
        smaller_path = file_path.gsub(full_path, "")
        smaller_path.gsub!(/^\//, '')

        gsub_big_file(smaller_path)
        f[:done] = true
      end
    end

    def gsub_big_file(smaller_path)
      puts "process big file #{smaller_path.to_s.green}"

      self.downloader.offline_tree.files.each do |f|
        if f[:inside]
          to_rename = f[:inside].select do |fi|
            fi[:path].index(smaller_path)
          end

          # TODO gsub path issue with html files inside
          to_rename.each do |fi|
            original_string = fi[:path]
            new_string = File.join(files_path, smaller_path)

            puts "rename big file #{original_string.to_s.blue} to #{new_string.to_s.green}"

            self.downloader.offline_tree.process_massive_gsub(original_string, new_string, true)
          end


        end
      end

    end

  end
end