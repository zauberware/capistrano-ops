# frozen_string_literal: true

namespace :figaro_yml do
  include Capistrano::Ops::FigaroYml::Paths
  include Capistrano::Ops::FigaroYml::Helpers
  task :check_figaro_file_exists do
    next if File.exist?(figaro_yml_local_path)

    check_figaro_file_exists_error
    exit 1
  end
end
