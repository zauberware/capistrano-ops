# frozen_string_literal: true

require 'capistrano/ops/helper'
require 'capistrano/ops/logs/paths'
require 'capistrano/ops/logs/helpers'

module TaskLoader
  extend Capistrano::Ops::Helper
  def self.load_tasks_if_gem_present(gem_name, task_path, warning_message)
    if gem_in_gemfile?(gem_name)
      Dir.glob("#{File.expand_path(__dir__)}/#{task_path}/**/*.rake").each { |f| load f }
    else
      puts warning_message
    end
  end
end

TaskLoader.load_tasks_if_gem_present('rails', 'logs/tasks', 'WARNING: Gemfile does not include rails gem which is required for logs tasks')
