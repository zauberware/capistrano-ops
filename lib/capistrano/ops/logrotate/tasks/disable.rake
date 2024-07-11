# frozen_string_literal: true

namespace :logrotate do
  include Capistrano::Ops::Logrotate::Paths
  include Capistrano::Ops::Logrotate::Helpers
  desc 'disable logrotate'
  task :disable do
    on roles(:app) do
      within release_path do
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
