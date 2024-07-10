# frozen_string_literal: true

namespace :logrotate do
  include Capistrano::Ops::Logrotate::Helpers
  include Capistrano::Ops::Logrotate::Paths

  desc 'Enable logrotate for the application'
  task :enable do
    on roles(:app) do
      within release_path do
        @log_file_path = log_file_path
        @shared_path = shared_path

        if logrotate_enabled
          puts "logrotate already enabled:\n========================="
          puts capture "cat #{logrotate_config_file_path}"
        else
          puts config_template
          puts schedule_template
          make_basepath
          upload! StringIO.new(config_template), logrotate_config_file_path
          upload! StringIO.new(schedule_template), logrotate_schedule_file_path
          whenever 'update' if logrotate_enabled
        end
      end
    end
  end
end
