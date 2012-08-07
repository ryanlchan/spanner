require 'rubygems'
require 'rake'

require 'rspec/core/rake_task'
$:.push File.expand_path("../lib", __FILE__)

task :default => :spec

RSpec::Core::RakeTask.new(:spec)

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "spanner-lfittl"
    s.description = s.summary = "Natural language time span parsing & formatting"
    s.email = "lukas@fittl.com"
    s.homepage = "http://github.com/lfittl/spanner"
    s.authors = ["Lukas Fittl", "Joshua Hull"]
    s.files = FileList["[A-Z]*", "{lib,spec}/**/*"]
    s.add_dependency 'activesupport'
    s.add_development_dependency 'jeweler'
    s.add_development_dependency 'rake'
    s.add_development_dependency 'rspec'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Run 'bundle install'."
end