# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ca_ching/version"

Gem::Specification.new do |s|
  s.name        = "ca_ching"
  s.version     = CaChing::Version.to_s
  s.authors     = ["Andrew Latimer"]
  s.email       = ["andrew@elpasoera.com"]
  s.homepage    = "http://github.com/ahlatimer/ca_ching"
  s.summary     = %q{Write-through ActiveRecord model caching that's right on the money}
  s.description = %q{Write-through ActiveRecord model caching that's right on the money}

  s.rubyforge_project = "ca_ching"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency 'hiredis'
  s.add_dependency 'redis', '2.2.2'
  s.add_dependency 'activesupport', '>= 3.1.0'
  s.add_dependency 'activerecord', '>= 3.1.0'
end
