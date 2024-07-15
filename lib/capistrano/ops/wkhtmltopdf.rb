# frozen_string_literal: true

require 'capistrano/ops/task_loader'
require 'capistrano/ops/wkhtmltopdf/helpers'

TaskLoader.load_tasks_if_gem_present('wicked_pdf', 'wkhtmltopdf/tasks',
                                     'WARNING: Gemfile does not include wkhtmltopdf-binary gem which is required for wkhtmltopdf tasks')
