require 'active_support/all'
require 'fileutils'

module Pedophile
  class Wget
    TMP_PATH = "tmp"
    TMP_ABSOLUTE_PATH = File.absolute_path(TMP_PATH)
    TMP_FILE_PATH = File.absolute_path(File.join(TMP_PATH, "tmp.tmp"))
    COOKIES_FILE_PATH = File.absolute_path(File.join(TMP_PATH, "cookies.txt"))
    TMP_OFFLINE_PATH = File.join(TMP_PATH, "site")

    WGET_PARAMS = "-v --random-wait --user-agent=Mozilla/5.0 --keep-session-cookies --load-cookies #{COOKIES_FILE_PATH} --save-cookies #{COOKIES_FILE_PATH}"
    # http://www.gnu.org/software/wget/manual/html_node/Download-Options.html
    #WGET_RESTRICT_FILE_NAMES = "windows" # windows, ascii, unix
    WGET_RESTRICT_FILE_NAMES = "unix"
    WGET_MIRROR_PARAMS = "--adjust-extension --mirror --page-requisites --convert-links --restrict-file-names=#{WGET_RESTRICT_FILE_NAMES}"

    def initialize(downloader)
      @downloader = downloader
      prepare_tmp_path
    end

    attr_reader :downloader

    def prepare_tmp_path
      Dir.mkdir(TMP_PATH) unless File.exists?(TMP_PATH)
      Dir.mkdir(TMP_OFFLINE_PATH) unless File.exists?(TMP_OFFLINE_PATH)
    end

    def download(url)
      `wget #{WGET_PARAMS} #{url} -O#{TMP_FILE_PATH}`
      File.open(TMP_FILE_PATH).read
    end

    def post(url, params)
      post_data = params.to_query
      `wget #{WGET_PARAMS} #{url} --post-data '#{post_data}' -O#{TMP_FILE_PATH}`
      File.open(TMP_FILE_PATH).read
    end

    def mirror
      `cd #{TMP_OFFLINE_PATH}; wget #{WGET_PARAMS} #{WGET_MIRROR_PARAMS} #{self.downloader.url}`
    end

    def clear!
      FileUtils.rm_rf(TMP_ABSOLUTE_PATH)
      prepare_tmp_path
    end

    def site_last_path
      (Dir.entries(Wget::TMP_OFFLINE_PATH) - ["..", "."]).first
    end

    def offline_path
      File.join(TMP_OFFLINE_PATH, site_last_path)
    end

  end
end