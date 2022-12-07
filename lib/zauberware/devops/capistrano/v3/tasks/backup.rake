# frozen_string_literal: true

namespace :backup do
  # Default to :app role
  rake_roles = fetch(:rake_roles, :app)

  desc 'create a backup of the server database'
  task :create do
    on roles(rake_roles) do
      env = "RAILS_ENV=#{fetch(:stage)}"
      # rubocop:disable Layout/LineLength
      path_cmd = "PATH=$HOME/.rbenv/versions/$(grep \"ruby '\" Gemfile | sed -e \"s/ruby\s'//g; s/'.\\{0,\\}//g\")/bin:$PATH"
      # rubocop:enable Layout/LineLength
      execute "cd #{release_path} && #{path_cmd} && #{env} BACKUPS_ENABLED=true bundle exec rake pg:dump"
    end
  end
  desc 'pull latest database backups from server to local'
  task :pull do
    on roles(rake_roles) do
      # rubocop:disable Layout/LineLength
      execute "cd #{shared_path}/backups && tar -czf #{shared_path}/backups.tar.gz $(ls -lt | grep -E -i '.{0,}\.dump' | head -n 1 | awk '{print $9}')"
      # rubocop:enable Layout/LineLength
      download! "#{shared_path}/backups.tar.gz", 'backups.tar.gz'
      execute "rm #{shared_path}/backups.tar.gz"
      system 'tar -xzf backups.tar.gz'
      system 'rm backups.tar.gz'
    end
  end
end
