# frozen_string_literal: true

namespace :figaro_yml do
  include Capistrano::Ops::FigaroYml::Paths
  include Capistrano::Ops::FigaroYml::Helpers
  task :check_git_tracking do
    next unless system("git ls-files #{fetch(:figaro_yml_local_path)} --error-unmatch >/dev/null 2>&1")

    check_git_tracking_error
    exit 1
  end
end
