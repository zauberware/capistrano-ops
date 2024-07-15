# frozen_string_literal: true

require 'capistrano/ops/helper'

module TaskLoader
  extend Capistrano::Ops::Helper

  def self.load_tasks_if_gem_present(gem_name, task_path, warning_message)
    unless gem_in_gemfile?(gem_name)
      warn warning_message
      return
    end

    base_path = File.expand_path(__dir__)
    task_files = Dir.glob("#{base_path}/#{task_path}/**/*.rake")

    task_files.each do |file|
      load file
    rescue StandardError => e
      puts "Failed to load #{file}: #{e.message}"
    end
  end
end
