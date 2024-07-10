# frozen_string_literal: true

namespace :figaro_yml do
  include Capistrano::Ops::FigaroYml::Helpers

  task :backup do
    on release_roles :all do
      unless remote_file_exists?
        puts 'No remote application.yml to backup.'
        next
      end

      begin
        puts 'Creating backup of remote application.yml...'
        create_remote_backup
        puts 'Backup created successfully.'

        puts 'Cleaning up remote backups...'
        cleanup_remote_backups
        puts 'Remote backups cleaned up successfully.'
      rescue StandardError => e
        puts "Error during backup process: #{e.message}"
      end
    end
  end
end
