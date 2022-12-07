module Zauberware
    module DevOps
        require 'zauberware/devops/railtie' if defined?(Rails)

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