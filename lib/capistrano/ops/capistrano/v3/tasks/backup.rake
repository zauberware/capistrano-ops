# frozen_string_literal: true

require_relative 'backup/backup_helper'

namespace :backup do
  include BackupHelper
  # Default to :app role
  rake_roles = fetch(:rake_roles, :app)

  desc 'create a backup of the server database (deprecated, use backup:database:create instead)'
  task :create do
    on roles(rake_roles) do
      warn "deprecated: use 'backup:database:create' instead, in future versions this task will be removed"
      execute "#{prepare_env} BACKUPS_ENABLED=true EXTERNAL_BACKUP_ENABLED=false bundle exec rake pg:dump"
    end
  end
  desc 'pull latest database backups from server to local (deprecated, use backup:database:pull instead)'
  task :pull do
    on roles(rake_roles) do
      warn "deprecated: use 'backup:database:pull' instead, in future versions this task will be removed"
      backup_file = backup_file_name('database')
      download! "#{shared_path}/backups/#{backup_file}"
    end
  end
end
