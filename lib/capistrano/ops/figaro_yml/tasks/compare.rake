# frozen_string_literal: true

namespace :figaro_yml do
  include Capistrano::Ops::FigaroYml::Paths
  include Capistrano::Ops::FigaroYml::Helpers

  desc 'compare and set the figaro_yml file on the server'
  task :compare do
    # Read and parse local application.yml
    local = local_figaro_yml(figaro_yml_env)

    # Split into stage-specific and global configurations
    local_global_env, local_stage_env = configs(local, figaro_yml_env)

    on release_roles :all do
      # Read and parse remote application.yml
      remote = YAML.safe_load(capture("cat #{figaro_yml_remote_path}"))
      remote_global_env, remote_stage_env = configs(remote, figaro_yml_env)

      # Compare hashes and handle nil results with empty hashes
      differences_global = compare_hashes(local_global_env, remote_global_env)
      differences_stage = compare_hashes(local_stage_env, remote_stage_env)

      print_changes(differences_global, 'Local application.yml has extra/different global entries compared to remote.')
      if differences_stage
        print_changes(differences_stage, "Local application.yml has extra/different entries in #{figaro_yml_env} section compared to remote.")
      end

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
