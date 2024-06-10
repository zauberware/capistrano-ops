# frozen_string_literal: true

require_relative 'logrotate_helper'

namespace :logrotate do
  include LogrotateHelper

  desc 'disable logrotate'
  task :disable do
    on roles(:app) do
      within release_path do
        set_config
        if logrotate_disabled
          puts 'logrotate already disabled'
        else
          whenever 'clear' if logrotate_enabled
          delete_files
        end
      end
    end
  end
end
