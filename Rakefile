require "spec"
require "spec/rake/spectask"
require 'lib/sax-mapper.rb'

Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

task :install do
  rm_rf "*.gem"
  puts `gem build sax-mapper.gemspec`
  puts `sudo gem install sax-mapper-#{SaxMapper::VERSION}.gem`
end