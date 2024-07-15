# frozen_string_literal: true

require 'capistrano/ops/task_loader'
require 'capistrano/ops/figaro_yml/paths'
require 'capistrano/ops/figaro_yml/helpers'

TaskLoader.load_tasks_if_gem_present('figaro', 'figaro_yml/tasks', 'WARNING: Gemfile does not include figaro gem which is required for figaro_yml tasks')
