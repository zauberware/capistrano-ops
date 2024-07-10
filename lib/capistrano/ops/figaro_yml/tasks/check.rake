# frozen_string_literal: true

namespace :figaro_yml do
  include Capistrano::Ops::FigaroYml::Paths
  include Capistrano::Ops::FigaroYml::Helpers
  desc 'figaro `application.yml` file checks'
  task :check do
    invoke 'figaro_yml:check_figaro_file_exists'
    invoke 'figaro_yml:check_git_tracking'
    invoke 'figaro_yml:check_config_present'
  end
end
