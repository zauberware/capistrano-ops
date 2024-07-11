# frozen_string_literal: true

namespace :load do
  task :defaults do
    set :figaro_yml_local_path, 'config/application.yml'
    set :figaro_yml_remote_path, 'config/application.yml'
    set :figaro_yml_env, -> { fetch(:rails_env) || fetch(:stage) }
    set :figaro_yml_remote_backup, false
  end
end
