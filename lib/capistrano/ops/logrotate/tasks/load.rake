# frozen_string_literal: true

namespace :load do
  task :defaults do
    set :logrotate_config_file_template, File.expand_path('templates/logrotate.conf.erb', __dir__)
    set :logrotate_schedule_file_template, File.expand_path('templates/schedule.rb.erb', __dir__)
    set :logrotate_basepath, 'logrotate'
    set :log_file_path, 'log'
  end
end
