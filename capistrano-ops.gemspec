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
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 3.2'
  s.add_dependency 'aws-sdk-s3', '~> 1.208'
  s.add_dependency 'faraday', '>= 2.0', '< 3.0'
  s.add_dependency 'nokogiri', '>= 1.15'
  s.add_dependency 'rails', '>= 7.2', '< 9'
  s.add_development_dependency 'bundler', '>= 2.4', '< 5'
  s.add_development_dependency 'bundler-audit', '~> 0.9'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rubocop', '~> 1.80'
  s.add_development_dependency 'rubocop-rake', '~> 0.7'
  s.add_development_dependency 'rubocop-rspec', '~> 3.0'
  s.metadata['rubygems_mfa_required'] = 'true'
end
