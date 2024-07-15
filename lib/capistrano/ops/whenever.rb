# frozen_string_literal: true

require 'capistrano/ops/task_loader'

TaskLoader.load_tasks_if_gem_present('whenever', 'whenever/tasks', 'WARNING: Gemfile does not include whenever gem which is required for whenever tasks')
