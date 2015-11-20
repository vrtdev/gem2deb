# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "install_as_gem"
  s.version     = '0.0.1'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Antonio Terceiro"]
  s.email       = ["terceiro@debian.org"]
  s.homepage    = ""
  s.summary     = %q{Simple gem to test the gem2deb gem installer}
  s.description = %q{Simple gem to test the gem2deb gem installer}

  s.files = Dir['**/*']
  s.executables = Dir['bin/*'].map { |f| File.basename(f) }
end
