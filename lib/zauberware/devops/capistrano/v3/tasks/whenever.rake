# frozen_string_literal: true

namespace :whenever do
  # Default to :app role
  rake_roles = fetch(:rake_roles, :app)
  desc 'show crontab'
  task :show_crontab do
    on roles(rake_roles) do
      puts capture 'crontab -l'
    end
  end
end
