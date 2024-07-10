# frozen_string_literal: true

namespace :figaro_yml do
  include Capistrano::Ops::FigaroYml::Paths
  include Capistrano::Ops::FigaroYml::Helpers
  rake_roles = fetch(:rake_roles, :app)

  task :get_stage do
    on roles(rake_roles) do
      raise 'The file does not exist.' unless test "[ -f #{figaro_yml_remote_path} ]"

      puts capture "cat #{figaro_yml_remote_path}"
    end
  end
end
