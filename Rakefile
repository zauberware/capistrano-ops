# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :version do
  desc 'Bump patch version (0.1.0 -> 0.1.1)'
  task :patch do
    ruby 'scripts/bump_version.rb patch'
  end

  desc 'Bump minor version (0.1.0 -> 0.2.0)'
  task :minor do
    ruby 'scripts/bump_version.rb minor'
  end

  desc 'Bump major version (0.1.0 -> 1.0.0)'
  task :major do
    ruby 'scripts/bump_version.rb major'
  end
end
