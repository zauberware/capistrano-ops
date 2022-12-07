# frozen_string_literal: true

require 'capistrano/version'

if defined?(Capistrano::VERSION) && Gem::Version.new(Capistrano::VERSION).release >= Gem::Version.new('3.0.0')
  load File.expand_path('capistrano/v3/tasks/whenever.rake', __dir__)
  load File.expand_path('capistrano/v3/tasks/backup.rake', __dir__)
  load File.expand_path('capistrano/v3/tasks/figaro_yml.rake', __dir__)
  load File.expand_path('capistrano/v3/tasks/logs.rake', __dir__)
else
  puts 'Capistrano 3 is required to use this gem'
end
