require "spec"
require "spec/rake/spectask"
require 'lib/saxual-replication.rb'

Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

task :install do
  rm_rf "*.gem"
  puts `gem build saxual-replication.gemspec`
  puts `sudo gem install saxual-replication-#{SAXualReplication::VERSION}.gem`
end