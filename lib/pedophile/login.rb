require 'uri'
require 'colorize'

module Pedophile
  class Login

    attr_reader :downloader

    def initialize(downloader)
      @downloader = downloader
    end

    def devise_login(url, email, password)
      uri = URI.parse(url)

      string = @downloader.wget.download(url)

      token = nil
      if string =~ /<input name=\"authenticity_token\" type=\"hidden\" value=\"([^"]+)\" \/>/
        token = $1
        puts "got devise token #{token.to_s.blue}"
      end

      action_url = nil
      if string =~ /action=\"([^"]+)\"/
        action_url = $1
        puts "got action url #{action_url.to_s.blue}"
      end

      sign_url = "http://#{uri.host}#{action_url}"
      puts "sign action url #{sign_url.to_s.blue}"

      post_params = {
        "authenticity_token" => token,
        "user" => {
          "email" => email,
          "password" => password,
          "remember_me" => 1
        }
      }
      post_params = {
        "utf8"=>"✓",
        "authenticity_token" => token,
        "user[email]" => email,
        "user[password]" => password,
        "user[remember_me]" => 1
      }

      string = @downloader.wget.post(url, post_params)
      string
    end

  end
end