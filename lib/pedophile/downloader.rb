require 'active_support/all'

module Pedophile
  class Downloader
    def initialize
      @login = Login.new(self)
      @wget = Wget.new(self)
      @offline_tree = OfflineTree.new(self)
      @big_files = BigFiles.new(self)
    end

    attr_reader :login, :wget, :offline_tree, :big_files
    attr_accessor :url

    def make_it_so
      wget.mirror
      offline_tree.make_it_so
    end

    def zip(name = "site.zip")
      offline_tree.zip(name)
    end

  end
end