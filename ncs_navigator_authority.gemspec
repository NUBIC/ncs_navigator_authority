# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ncs_navigator/authorization/version"

Gem::Specification.new do |s|
  s.name        = "ncs_navigator_authority"
  s.version     = NcsNavigator::Authorization::VERSION
  s.authors     = ["Jalpa Patel"]
  s.email       = ["jalpa-patel@northwestern.edu"]
  s.homepage    = ""
  s.summary     = %q{Authorization module for NCS Navigator}
  s.description = %q{This is a shared library which consume Staff Portal's authorization API and provides group membership information for the NcsNavigator portal and role authorization mapping for PSC.} 

  s.rubyforge_project = "ncs_navigator_authority"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency 'ncs_navigator_configuration', '~> 0.2'
  s.add_dependency 'aker', '~> 3.0'
  s.add_dependency 'faraday', '~> 0.7.5'
  s.add_dependency 'faraday_middleware'
  
  s.add_development_dependency 'rspec', '~> 2.6'
  s.add_development_dependency 'rake', '~> 0.9.2'
  s.add_development_dependency 'vcr', '~> 1.0'
  s.add_development_dependency 'fakeweb'

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
