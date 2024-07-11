# frozen_string_literal: true

require 'capistrano/version'
require 'capistrano/ops/whenever'
require 'capistrano/ops/figaro_yml'
require 'capistrano/ops/logrotate'
require 'capistrano/ops/logs'
require 'capistrano/ops/invoke'
require 'capistrano/ops/backup'

unless defined?(Capistrano::VERSION) && Gem::Version.new(Capistrano::VERSION).release >= Gem::Version.new('3.0.0')
  puts 'Capistrano 3 is required to use this gem'
end
