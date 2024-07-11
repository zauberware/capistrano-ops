# frozen_string_literal: true

namespace :whenever do
  desc 'show crontab'
  task :show_crontab do
    on roles(fetch(:rake_roles, :app)) do
      puts capture 'crontab -l'
    end
  end
end
