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
  gem.name = "ephemeral"
  gem.homepage = "http://github.com/Bantik/ephemeral"
  gem.license = "MIT"
  gem.summary = %Q{Ephemeral is an ODM for in-memory collections of objects.}
  gem.description = %Q{Ephemeral lets you define one-to-many relationships between in-memory objects, with ORM-like support for where clauses and chainable scopes.}
  gem.email = "corey@idolhands.com"
  gem.authors = ["Corey Ehmke"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ephemeral #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
