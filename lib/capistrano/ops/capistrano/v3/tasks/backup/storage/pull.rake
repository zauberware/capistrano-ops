# frozen_string_literal: true

require_relative '../backup_helper'
namespace :backup do
  namespace :storage do
    include BackupHelper
    # Default to :app role
    rake_roles = fetch(:rake_roles, :app)
    desc 'pull latest storage dump from server to local'
    task :pull do
      on roles(rake_roles) do
        puts 'Creating temporary backup...'
        execute "#{prepare_env} BACKUPS_ENABLED=true EXTERNAL_BACKUP_ENABLED=false bundle exec rake storage:backup"
        puts 'Backup created'
        backup_file = backup_file_name('storage')
        backup_size = backup_file_size

        puts 'Prepare download...'

        question("Backup size: #{size_str(backup_size.to_i)}. Continue?", 'n') do |answer|
          if answer
            download_backup(backup_file, 'storage')
          else
            cleanup_backup(backup_file, "Aborting...\nDeleting temporary backup...")
          end
        end
      end
    end
  end
end
