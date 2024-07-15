# frozen_string_literal: true

require 'capistrano/ops/task_loader'
require 'capistrano/ops/logrotate/helpers'
require 'capistrano/ops/logrotate/paths'

TaskLoader.load_tasks_if_gem_present('whenever', 'logrotate/tasks', 'WARNING: Gemfile does not include whenever gem which is required for logrotate tasks')
