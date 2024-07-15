# frozen_string_literal: true

require 'capistrano/ops/task_loader'
require 'capistrano/ops/backup/helper'

TaskLoader.load_tasks_if_gem_present('rails', 'backup/tasks', 'WARNING: Gemfile does not include rails gem which is required for backup tasks')
