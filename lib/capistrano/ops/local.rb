# frozen_string_literal: true

require 'capistrano/ops/task_loader'
require 'capistrano/ops/local/helpers'

TaskLoader.load_tasks_if_gem_present(
  'capistrano-rails', 'local/tasks',
  'WARNING: Gemfile does not include capistrano-rails gem which is required for local:console (provides capistrano/rails/console)'
)
