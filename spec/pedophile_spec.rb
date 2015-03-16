require 'spec_helper'

download_sample_rails_app = false

describe Pedophile::Downloader do
  it "download sample rails app (localhost:3000)" do
    if download_sample_rails_app
      p = Pedophile::Downloader.new
      p.url = "http://localhost:3000/"

      p.wget.clear!
      p.login.devise_login("http://localhost:3000/login", "email@email.com", "password")

      ## theese lines were moved to one method
      ## as a Picard fun - 'make it so'
      #p.wget.mirror
      #
      #p.offline_tree.analyze
      #p.offline_tree.load_analyzed
      #
      #p.offline_tree.process_bad_suffix1
      #p.offline_tree.process_bad_suffix2
      #p.offline_tree.process_bad_filenames
      #p.offline_tree.save_analyzed
      #p.offline_tree.save_changes

      p.make_it_so
    end
  end

  it "download simple webpage" do
    p = Pedophile::Downloader.new
    p.url = "http://www.classnamer.com/"

    p.wget.clear!
    p.make_it_so
    p.zip
  end

end


