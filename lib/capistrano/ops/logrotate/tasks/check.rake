# frozen_string_literal: true

namespace :logrotate do
  include Capistrano::Ops::Logrotate::Helpers
  include Capistrano::Ops::Logrotate::Paths

  desc 'show logrotate state and config'
  task :check do
    on roles(:app) do
      within release_path do
        if logrotate_enabled
          puts "logrotate running with config\n========================="
          puts capture "cat #{logrotate_config_file_path}"
        else
          puts 'logrotate disabled'
        end
      end
    end
  end
end
