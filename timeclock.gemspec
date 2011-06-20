# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "timeclock/version"

Gem::Specification.new do |s|
  s.name        = "timeclock"
  s.version     = Timeclock::VERSION
  s.authors     = ["Lyon"]
  s.email       = ["lyon@delorum.com"]
  s.homepage    = ""
  s.summary     = %q{Time clock because I dont like filling out those cards}
  s.description = %q{DUH}

  s.rubyforge_project = "timeclock"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
