# frozen_string_literal: true

namespace :figaro_yml do
  include Capistrano::Ops::FigaroYml::Helpers

  task :rollback do
    on release_roles :all do
      unless remote_backup_exists?
        puts 'No backup of remote application.yml to rollback.'
        next
      end

      begin
        puts 'Rolling back remote application.yml...'
        rollback_remote_backup
        puts 'Rollback completed successfully.'
      rescue StandardError => e
        puts "Error during rollback process: #{e.message}"
      end
    end
  end
end
