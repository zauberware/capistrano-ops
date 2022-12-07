# frozen_string_literal: true

namespace :logs do
  # Default to :app role
  rake_roles = fetch(:rake_roles, :app)
  desc 'tail rails logs'
  task :rails do
    on roles(rake_roles) do
      trap('SIGINT') do
        puts "\nDisconnecting..."
        exit
      end
      execute "tail -f #{shared_path}/log/#{fetch(:rails_env)}.log"
    end
  end
end
