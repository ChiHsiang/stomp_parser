# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stompede/version'

Gem::Specification.new do |spec|
  spec.name          = "stompede"
  spec.version       = Stompede::VERSION
  spec.authors       = ["Kim Burgestrand"]
  spec.email         = ["kim@burgestrand.se"]
  spec.summary       = %q{STOMP over WebSockets for Ruby.}
  spec.homepage      = "https://github.com/Burgestrand/stompede"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.files        += ["lib/stompede/stomp/ruby_parser.rb"]
  spec.files        += ["ext/stompede/c_parser.c"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.extensions    = %w[ext/stompede/extconf.rb]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rake-compiler"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end
