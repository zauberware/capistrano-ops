require 'pathname'

module Capistrano
  module Ops
    module Logrotate
      module Paths
        # local paths
        def logrotate_config_file_template
          Pathname.new fetch(:logrotate_config_file_template)
        end

        def logrotate_schedule_file_template
          Pathname.new fetch(:logrotate_schedule_file_template)
        end

        # remote paths
        def logrotate_basepath
          shared_path.join fetch(:logrotate_basepath)
        end

        def logrotate_config_path
          shared_path.join fetch(:logrotate_config_path)
        end

        def logrotate_config_file_path
          logrotate_basepath.join logrotate_config_filename
        end

        def logrotate_schedule_file_path
          logrotate_basepath.join logrotate_schedule_filename
        end

        def log_file_path
          shared_path.join fetch(:log_file_path)
        end

        def logrotate_schedule_filename
          File.basename(logrotate_schedule_file_template, '.erb')
        end

        def logrotate_config_filename
          File.basename(logrotate_config_file_template, '.erb')
        end
      end
    end
  end
end
