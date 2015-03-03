require 'spec_helper'

describe Pedophile::Downloader do
  it "download sample page" do
    p = Pedophile::Downloader.new
    p.url = "http://localhost:3000/"

    p.login.devise_login("http://localhost:3000/login", "email@email.com", "password")
    p.wget.mirror

    p.offline_tree.process
    #p.offline_tree.load_processed
    #p.offline_tree.rename_files
    #p.offline_tree.remove_bad_suffix
    #p.offline_tree.perform_massive_html_change("%3Fbody=1", "")

    p.offline_tree.after_process
  end
end
