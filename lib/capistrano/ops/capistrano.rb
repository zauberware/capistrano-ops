# frozen_string_literal: true

require 'capistrano/version'

if defined?(Capistrano::VERSION) && Gem::Version.new(Capistrano::VERSION).release >= Gem::Version.new('3.0.0')
  load File.expand_path('capistrano/v3/tasks/whenever.rake', __dir__)
  load File.expand_path('capistrano/v3/tasks/backup.rake', __dir__)
  load File.expand_path('capistrano/v3/tasks/figaro_yml.rake', __dir__)
  load File.expand_path('capistrano/v3/tasks/invoke.rake', __dir__)
  path = File.expand_path(__dir__)
  Dir.glob("#{path}/capistrano/v3/tasks/backup/**/*.rake").each { |f| load f }
  Dir.glob("#{path}/capistrano/v3/tasks/logrotate/**/*.rake").each { |f| load f }
  Dir.glob("#{path}/capistrano/v3/tasks/logs/**/*.rake").each { |f| load f }
else
  puts 'Capistrano 3 is required to use this gem'
end
