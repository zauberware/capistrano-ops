# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'zauberware/devops/version'

Gem::Specification.new do |s|
  s.name          = 'zauberware-devops'
  s.version       = Zauberware::DevOps::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Florian Crusius']
  s.email         = ['florian@zauberware.com']
  s.license       = 'MIT'
  s.homepage      = 'https://github.com/zauberware/zauberware-devops'
  s.summary       = 'devops tasks for rails applications'
  s.description   = 'A collection of devops tasks for rails applications'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/{functional,unit}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'bundler', '~> 1.11'
  s.add_development_dependency 'rake', '~> 10.0'
end
