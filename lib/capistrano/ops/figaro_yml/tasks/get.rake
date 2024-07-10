# frozen_string_literal: true

namespace :figaro_yml do
  include Capistrano::Ops::FigaroYml::Paths
  include Capistrano::Ops::FigaroYml::Helpers
  task :get do
    if !File.exist?(figaro_yml_local_path)
      invoke 'figaro_yml:create_local'
    else
      local_yml = local_figaro_yml(figaro_yml_env)
      local_global, local_stage = configs(local_yml, figaro_yml_env)
      on release_roles :all do
        remote = capture "cat #{figaro_yml_remote_path}"
        remote_yml = YAML.safe_load(remote).sort.to_h
        remote_global, remote_stage = configs(remote_yml, figaro_yml_env)
        differences_global = compare_hashes(remote_global, local_global || {})
        differences_stage = compare_hashes(remote_stage, local_stage || {})

        print_changes(differences_global,
                      'Remote application.yml has extra/different global entries compared to local.')
        if differences_stage
          print_changes(differences_stage, "Remote application.yml has extra/different entries in #{figaro_yml_env} section compared to local.")
        end

        puts 'No Differences found between remote and local application.yml' unless differences_global || differences_stage

        # ask to overwrite local yml if differences found
        stage_overwrite = ask_to_overwrite("Overwrite local application.yml #{figaro_yml_env} section") if differences_stage
        global_overwrite = ask_to_overwrite('Overwrite local application.yml globals') if differences_global
        puts 'Nothing written to local application.yml' unless stage_overwrite || global_overwrite
        exit unless stage_overwrite || global_overwrite

        # compose new yml
        composed_yml = {}
        composed_yml.merge!(local_yml) # local yml is always included to avoid losing any data
        composed_yml.merge!(local_global) unless global_overwrite
        composed_yml.merge!(remote_global) if global_overwrite
        composed_yml[figaro_yml_env.to_s] = stage_overwrite ? remote_stage : local_stage

        # write to new file
        write_combined_yaml(composed_yml.sort.to_h)
      end
    end
  end
end
