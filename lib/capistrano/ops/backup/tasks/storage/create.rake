# frozen_string_literal: true

namespace :backup do
  namespace :storage do
    include Capistrano::Ops::Backup::Helper
    # Default to :app role
    rake_roles = fetch(:rake_roles, :app)

    desc 'create storage dump on server'
    task :create do
      on roles(rake_roles) do
        puts 'Creating backup...'
        execute "#{prepare_env} BACKUPS_ENABLED=true EXTERNAL_BACKUP_ENABLED=false bundle exec rake storage:backup"
      end
    end
  end
end
