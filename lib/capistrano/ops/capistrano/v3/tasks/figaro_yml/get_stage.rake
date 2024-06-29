# frozen_string_literal: true

require_relative 'figaro_yaml_helper'

namespace :figaro_yml do
  rake_roles = fetch(:rake_roles, :app)

  task :get_stage do
    on roles(rake_roles) do
      puts capture "cat #{shared_path}/config/application.yml"
    end
  end
end
