# frozen_string_literal: true

require_relative 'figaro_yaml_helper'

namespace :figaro_yml do
  include FigaroYmlHelper
  rake_roles = fetch(:rake_roles, :app)

  desc 'compare and set the figaro_yml file on the server'
  task :compare do
    env = fetch(:stage).to_s
    # Read and parse local application.yml
    local = local_yaml

    # Split into stage-specific and global configurations
    local_global_env, local_stage_env = configs(local, env)

    # puts local_global_env.to_yaml
    # puts "\n\n\n"
    # puts({ env => local_stage_env }.to_yaml)
    on roles(rake_roles) do
      # Read and parse remote application.yml
      remote = YAML.safe_load(capture("cat #{shared_path}/config/application.yml"))
      remote_global_env, remote_stage_env = configs(remote, env)

      # puts remote_global_env.to_yaml
      # puts "\n\n\n"
      # puts({ env => remote_stage_env }.to_yaml)
      # puts "Comparing local and remote application.yml for '#{env}' environment..."

      # Compare hashes and handle nil results with empty hashes
      differences_global = compare_hashes(local_global_env, remote_global_env)
      differences_stage = compare_hashes(local_stage_env, remote_stage_env)

      print_changes(differences_global, 'Local application.yml has extra/different global entries compared to remote.')
      print_changes(differences_stage, "Local application.yml has extra/different entries in #{env} section compared to remote.") if differences_stage

      puts 'No Differences found between remote and local application.yml' unless differences_global || differences_stage

      # ask to overwrite remote yml if differences found
      overwrite_remote = ask_to_overwrite('Overwrite remote application.yml') if differences_global || differences_stage
      puts 'Nothing written to remote application.yml' unless overwrite_remote

      exit unless overwrite_remote
      # sort local yml before updating remote
      puts 'Preparing local application.yml before updating remote...'
      invoke 'figaro_yml:sort_local'
      puts 'Local application.yml is ready to be updated.'

      # update remote yml
      invoke 'figaro_yml:setup'
      ##
      # TODO: restart server after updating remote yml
      # let user choose to restart server after updating remote yml
      # let user choose to restart server now or later if they choose to restart now
      # ask for time to restart server if he chooses to restart later
      # restart server after the time given
      ##
      puts 'Remote application.yml has been updated.'
    end
  end
end
