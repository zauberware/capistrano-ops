# frozen_string_literal: true

namespace :backup do
  namespace :database do
    include Capistrano::Ops::Backup::Helper
    # Default to :app role
    rake_roles = fetch(:rake_roles, :app)

    desc 'pull latest database dump from server to local'
    task :pull do
      on roles(rake_roles) do
        puts 'Creating temporary backup...'
        execute "#{prepare_env} BACKUPS_ENABLED=true EXTERNAL_BACKUP_ENABLED=false bundle exec rake pg:dump"
        puts "Backup created\nPrepare download..."
        backup_file = backup_file_name('database')
        backup_size = backup_file_size
        question("Backup size: #{size_str(backup_size.to_i)}. Continue?", 'n') do |answer|
          if answer
            download_backup(backup_file, 'database')
          else
            cleanup_backup(backup_file, "Aborting...\nDeleting temporary backup...")
          end
        end
      end
    end
  end
end
