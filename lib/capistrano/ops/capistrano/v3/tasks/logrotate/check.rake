# frozen_string_literal: true

require_relative 'logrotate_helper'

namespace :logrotate do
  include LogrotateHelper

  desc 'show logrotate state and config'
  task :check do
    on roles(:app) do
      within release_path do
        set_config
        if logrotate_enabled
          puts "logrotate running with config\n========================="
          puts capture "cat #{@config_file_path}"
        else
          puts 'logrotate disabled'
        end
      end
    end
  end
end
