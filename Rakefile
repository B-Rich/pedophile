# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "pedophile"
  gem.homepage = "http://github.com/akwiatkowski/pedophile"
  gem.license = "LGPLv3"
  gem.summary = %Q{download static pages for offline usage}
  gem.description = %Q{download static pages for offline usage.}
  gem.email = "bobikx@poczta.fm"
  gem.authors = ["Aleksander Kwiatkowski"]
  # dependencies defined in Gemfile

  gem.files = FileList[
    "[A-Z]*", "{bin,generators,lib,test}/**/*"
  ]
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rdoc/task'

desc "Run RSpec with code coverage"
task :coverage do
  `rake spec COVERAGE=true`
  #`open coverage/index.html`
end