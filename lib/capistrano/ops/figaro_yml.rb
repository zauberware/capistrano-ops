# frozen_string_literal: true

require 'capistrano/ops/helper'
require 'capistrano/ops/figaro_yml/paths'
require 'capistrano/ops/figaro_yml/helpers'

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

TaskLoader.load_tasks_if_gem_present('figaro', 'figaro_yml/tasks', 'WARNING: Gemfile does not include figaro gem which is required for figaro_yml tasks')
# include Capistrano::Ops::Helper

# Dir.glob("#{File.expand_path(__dir__)}/figaro_yml/tasks/*.rake").each { |f| load f }

# # gem 'figaro' is required for figaro_yml tasks

# figaro_gem = gem_in_gemfile?('figaro')

# # check if Gemfile environment includes figaro gem and warn user if not found
# puts 'WARNING: Gemfile does not include figaro gem which is required for figaro_yml tasks' unless figaro_gem
