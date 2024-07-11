# frozen_string_literal: true

module Capistrano
  module Ops
    require 'capistrano/ops/rails/lib/backup'
    require 'capistrano/ops/rails/lib/notification'
    require 'capistrano/ops/rails/lib/railtie' if defined?(Rails)
    require 'capistrano/ops/capistrano' if defined?(Capistrano::VERSION)

    def self.path
      Dir.pwd
    end

    def self.bin_rails?
      File.exist?(File.join(path, 'bin', 'rails'))
    end

    def self.script_rails?
      File.exist?(File.join(path, 'script', 'rails'))
    end

    def self.bundler?
      File.exist?(File.join(path, 'Gemfile'))
    end
  end
end
