# frozen_string_literal: true

require 'capistrano/ops/task_loader'
require 'capistrano/ops/logs/paths'
require 'capistrano/ops/logs/helpers'

TaskLoader.load_tasks_if_gem_present('rails', 'logs/tasks', 'WARNING: Gemfile does not include rails gem which is required for logs tasks')
