# frozen_string_literal: true

module Capistrano
  module Ops
    module Logrotate
      module Helpers
        def config_template
          return nil unless File.exist?(File.expand_path(logrotate_config_file_template, __dir__))

          ERB.new(File.read(File.expand_path(logrotate_config_file_template, __dir__))).result(binding)
        end

        def schedule_template
          return nil unless File.exist?(File.expand_path(logrotate_schedule_file_template, __dir__))

          ERB.new(File.read(File.expand_path(logrotate_schedule_file_template, __dir__))).result(binding)
        end

        def logrotate_enabled
          test("[ -f #{logrotate_config_file_path} ]") && test("[ -f #{logrotate_schedule_file_path} ]")
        end

        def logrotate_disabled
          !(test("[ -f #{logrotate_config_file_path} ]") && test("[ -f #{logrotate_schedule_file_path} ]"))
        end

        def make_basepath
          puts capture "mkdir -pv #{logrotate_basepath}"
        end

        def delete_files
          puts capture "rm -rfv #{logrotate_basepath}"
        end

        def whenever(type)
          case type
          when 'clear'
            puts capture :bundle, :exec, :whenever, '--clear-crontab',
                         "-f #{logrotate_schedule_file_path} #{fetch(:whenever_identifier)}_logrotate"
          when 'update'
            puts capture :bundle, :exec, :whenever, '--update-crontab', "-f #{logrotate_schedule_file_path}",
                         "-i #{fetch(:whenever_identifier)}_logrotate"
          else
            puts 'type not found'
          end
        end
      end
    end
  end
end
