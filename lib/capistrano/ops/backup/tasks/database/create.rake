# frozen_string_literal: true

namespace :backup do
  namespace :database do
    include Capistrano::Ops::Backup::Helper
    # Default to :app role
    rake_roles = fetch(:rake_roles, :app)

    desc 'create a backup of the server database'
    task :create do
      on roles(rake_roles) do
        puts 'Creating backup...'
        execute "#{prepare_env} BACKUPS_ENABLED=true bundle exec rake pg:dump"
      end
    end
  end
end
