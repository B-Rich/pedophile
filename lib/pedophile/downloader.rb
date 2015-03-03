require 'active_support/all'

module Pedophile
  class Downloader
    def initialize
      @login = Login.new(self)
      @wget = Wget.new(self)
      @offline_tree = OfflineTree.new(self)
    end

    attr_reader :login, :wget, :offline_tree
    attr_accessor :url

  end
end