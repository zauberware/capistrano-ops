# frozen_string_literal: true

require 'pathname'

module Capistrano
  module Ops
    module Logs
      module Paths
        def rails_log_file_path
          shared_path.join fetch(:rails_log_file_name) || "log/#{fetch(:rails_env)}.log"
        end

        def sidekiq_log_file_path
          shared_path.join fetch(:sidekiq_log_file_name) || 'log/sidekiq.log'
        end

        def sidekiq_error_log_file_path
          shared_path.join fetch(:sidekiq_error_log_file_name) || 'log/sidekiq.error.log'
        end
      end
    end
  end
end
