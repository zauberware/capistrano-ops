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

  s.required_ruby_version = '>= 2.7.0', '< 3.3.0'
  s.add_dependency 'aws-sdk-s3', '~> 1.175'
  s.add_dependency 'faraday'
  s.add_dependency 'nokogiri'
  s.add_dependency 'rails'
  s.add_development_dependency 'bundler', '~> 2.4.12'
  s.add_development_dependency 'rake', '~> 12.3'
  s.add_development_dependency 'rubocop', '~> 1.56.2' # rubocop ruby
  s.add_development_dependency 'rubocop-performance', '~> 1.19.0' # speed up rubocop
end
