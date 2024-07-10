# frozen_string_literal: true

namespace :figaro_yml do
  include Capistrano::Ops::FigaroYml::Paths
  include Capistrano::Ops::FigaroYml::Helpers
  task :check_config_present do
    next unless local_figaro_yml(figaro_yml_env).nil?

    check_config_present_error
    exit 1
  end
end
