# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'capistrano/ops/version'

Gem::Specification.new do |s|
  s.name          = 'capistrano-ops'
  s.version       = Capistrano::Ops::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Florian Crusius']
  s.email         = ['florian@zauberware.com']
  s.license       = 'MIT'
  s.homepage      = 'https://github.com/zauberware/capistrano-ops'
  s.summary       = 'devops tasks for rails applications'
  s.description   = 'A collection of devops tasks for rails applications'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/{functional,unit}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'bundler', '~> 2.3.9'
  s.add_development_dependency 'rake', '~> 10.0'
end