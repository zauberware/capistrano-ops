# frozen_string_literal: true

namespace :load do
  task :defaults do
    set :rails_log_file_name, nil
    set :sidekiq_log_file_name, nil
    set :sidekiq_error_log_file_name, nil
  end
end
