

module Capistrano
    module Ops
        require 'capistrano/ops/backup'
        require 'capistrano/ops/notification'
        require 'capistrano/ops/railtie' if defined?(Rails)
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