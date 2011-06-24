# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "timeclock/version"

Gem::Specification.new do |s|
  s.name        = "timeclock"
  s.version     = Timeclock::VERSION
  s.authors     = ["Lyon"]
  s.email       = ["lyon@delorum.com"]
  s.homepage    = ""
  s.summary     = %q{Timeclock is a small but useful timeclock system that allows users to push clock in and clock out. additionally you can see your daily time totals and you can also send your clock invoice to an email}
  s.description = %q{A simple console based clock in/clock out system.}

  s.rubyforge_project = "timeclock"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
