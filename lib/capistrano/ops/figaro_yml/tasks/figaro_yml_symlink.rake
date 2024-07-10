# frozen_string_literal: true

namespace :figaro_yml do
  include Capistrano::Ops::FigaroYml::Paths
  include Capistrano::Ops::FigaroYml::Helpers
  task :figaro_yml_symlink do
    set :linked_files, fetch(:linked_files, []).push(fetch(:figaro_yml_remote_path))
  end
  after 'deploy:started', 'figaro_yml:figaro_yml_symlink'
end
