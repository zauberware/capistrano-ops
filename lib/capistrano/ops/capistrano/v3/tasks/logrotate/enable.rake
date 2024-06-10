# frozen_string_literal: true

require_relative 'logrotate_helper'

namespace :logrotate do
  include LogrotateHelper
  desc 'Enable logrotate for the application'
  task :enable do
    on roles(:app) do
      within release_path do
        set_config
        if logrotate_enabled
          puts "logrotate already enabled:\n========================="
          puts capture "cat #{@config_file_path}"
        else
          make_basepath
          upload! StringIO.new(@config_template), @config_file_path
          upload! StringIO.new(@schedule_template), @schedule_file_path
          whenever 'update' if logrotate_enabled
        end
      end
    end
  end
end
