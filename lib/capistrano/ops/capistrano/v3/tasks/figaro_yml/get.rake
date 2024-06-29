# frozen_string_literal: true

require_relative 'figaro_yaml_helper'

namespace :figaro_yml do
  include FigaroYmlHelper

  rake_roles = fetch(:rake_roles, :app)
  desc 'get the `application.yml` file from server and create local if it does not exist'
  task :get do
    env = fetch(:stage)
    if !File.exist?('config/application.yml')
      run_locally do
        puts "found #{environments.count} stages"
        yamls_combined = {}

        stages.each do |f|
          stage = File.basename(f, '.rb')
          puts "download #{stage} application.yml"
          begin
            res = capture "cap #{stage} figaro_yml:get_stage"
            stage_yaml = YAML.safe_load(res)
            stage_yaml[stage.to_s] = stage_yaml[stage.to_s].sort.to_h
            yamls_combined.merge!(stage_yaml) if stage_yaml
          rescue StandardError
            puts "could not get #{stage} application.yml"
          end
        end

        write_combined_yaml(yamls_combined.sort.to_h)
      end
    else
      on roles(rake_roles) do
        local_yml = local_yaml.sort.to_h
        local_global, local_stage = configs(local_yml, env)

        remote = capture("cat #{shared_path}/config/application.yml")
        remote_yml = YAML.safe_load(remote).sort.to_h
        remote_global, remote_stage = configs(remote_yml, env)

        differences_global = compare_hashes(remote_global, local_global || {})
        differences_stage = compare_hashes(remote_stage, local_stage || {})

        print_changes(differences_global,
                      'Remote application.yml has extra/different global entries compared to local.')
        print_changes(differences_stage, "Remote application.yml has extra/different entries in #{env} section compared to local.") if differences_stage

        puts 'No Differences found between remote and local application.yml' unless differences_global || differences_stage

        # ask to overwrite local yml if differences found
        stage_overwrite = ask_to_overwrite("Overwrite local application.yml #{env} section") if differences_stage
        global_overwrite = ask_to_overwrite('Overwrite local application.yml globals') if differences_global
        puts 'Nothing written to local application.yml' unless stage_overwrite || global_overwrite
        exit unless stage_overwrite || global_overwrite

        # compose new yml
        composed_yml = {}
        composed_yml.merge!(local_yml) # local yml is always included to avoid losing any data
        composed_yml.merge!(local_global) unless global_overwrite
        composed_yml.merge!(remote_global) if global_overwrite
        composed_yml[env.to_s] = stage_overwrite ? remote_stage : local_stage

        # write to new file
        write_combined_yaml(composed_yml.sort.to_h)
      end
    end
  end
end
