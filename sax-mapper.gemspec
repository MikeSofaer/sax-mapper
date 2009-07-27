# -*- encoding: utf-8 -*-
 
Gem::Specification.new do |s|
  s.name = %q{sax-mapper}
  s.version = "0.0.1"
 
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Sofaer"]
  s.date = %q{2009-07-21}
  s.email = %q{mike@sofaer.net}
  s.files = [
    "lib/sax-mapper.rb", 
    "README", "Rakefile",
    "spec/spec.opts", 
    "spec/spec_helper.rb", 
    "spec/sax-mapper/sax-mapper_spec.rb"]
  s.homepage = %q{http://github.com/MikeSofaer/sax-mapper}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Database replication from XML with SAXMachine}
  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2
 
    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<pauldix-sax-machine>, [">= 0.0.14"])
      s.add_runtime_dependency(%q<dm-core>, [">= 0.0.0"])
    else
      s.add_dependency(%q<pauldix-sax-machine>, [">= 0.0.14"])
      s.add_dependency(%q<dm-core>, [">= 0.0.0"])
    end
  else
    s.add_dependency(%q<pauldix-sax-machine>, [">= 0.0.14"])
    s.add_dependency(%q<dm-core>, [">= 0.0.0"])
  end
end