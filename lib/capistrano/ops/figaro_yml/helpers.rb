# frozen_string_literal: true

require 'yaml'

# rubocop:disable Metrics/ModuleLength
module Capistrano
  module Ops
    module FigaroYml
      module Helpers
        def remote_file_exists?
          test("[ -f #{figaro_yml_remote_path} ]")
        end

        def remote_backup_exists?
          count_remote_files.positive?
        end

        def rollback_remote_backup
          latest_backup = latest_remote_backup
          puts "mv #{figaro_yml_remote_path.parent.join(latest_backup)} #{figaro_yml_remote_path}"
          execute :mv, figaro_yml_remote_path.parent.join(latest_backup), figaro_yml_remote_path
          execute :ls, '-l', figaro_yml_remote_path.parent
        end

        def latest_remote_backup
          command = "ls -1t #{figaro_yml_remote_path.parent} | grep -E '#{backup_regex}' | head -n 1"
          capture(command).strip
        end

        def backup_regex
          # filename we are looking for "#{figaro_yml_remote_path.basename}-yyyy-mm-dd-HH-MM-SS.bak"
          "#{figaro_yml_remote_path.basename}-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}.bak"
        end

        def count_remote_files
          command = "ls -1 #{figaro_yml_remote_path.parent} | grep -E '#{backup_regex}' | wc -l"
          capture(command).to_i
        end

        def create_remote_backup
          backup_file = "#{figaro_yml_remote_path.basename}-#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}.bak"
          # puts "cp #{figaro_yml_remote_path} #{figaro_yml_remote_path.parent.join(backup_file)}"
          execute :cp, figaro_yml_remote_path, figaro_yml_remote_path.parent.join(backup_file)
        end

        def cleanup_remote_backups
          number_of_backups = count_remote_files
          return unless number_of_backups > 5

          diff = number_of_backups - 5
          # remove older backups and keep the latest 5
          command = "ls -1t #{figaro_yml_remote_path.parent} | grep -E '#{backup_regex}' | tail -n #{diff}"

          capture(command).split("\n").each do |file|
            execute "rm #{figaro_yml_remote_path.parent.join(file)}"
          end
        end

        def local_figaro_yml(env)
          @local_figaro_yml ||= YAML.load(ERB.new(File.read(figaro_yml_local_path)).result)
          local_figaro = {}
          deployment_env = fetch(:rails_env, env).to_s

          @local_figaro_yml.each do |key, value|
            if key == env
              local_figaro[deployment_env] = @local_figaro_yml[key]
            elsif !value.is_a?(Hash)
              local_figaro[key] = @local_figaro_yml[key]
            end
          end

          local_figaro
        end

        def local_yaml
          YAML.safe_load(File.read(figaro_yml_local_path)) || {}
        end

        def figaro_yml_env
          fetch(:figaro_yml_env).to_s
        end

        def figaro_yml_content
          local_figaro_yml(figaro_yml_env).to_yaml
        end

        def configs(yaml, env)
          stage_yml = yaml[env.to_s]&.sort.to_h
          global_yml = remove_nested(yaml)&.sort.to_h
          [global_yml, stage_yml]
        end

        def remove_nested(hash)
          hash.each_with_object({}) do |(key, value), new_hash|
            new_hash[key] = value unless value.is_a?(Hash)
          end
        end

        def sort_with_nested(hash)
          hash.each_with_object({}) do |(key, value), new_hash|
            new_hash[key] = value.is_a?(Hash) ? sort_with_nested(value) : value
          end.sort.to_h
        end

        def compare_hashes(hash1, hash2)
          all_keys = hash1.keys | hash2.keys # Union of all keys from both hashes
          all_keys.each_with_object({}) do |key, changes_hash|
            old_value = hash2[key].nil? ? 'nil' : hash2[key].to_s
            new_value = hash1[key].nil? ? 'nil' : hash1[key].to_s

            changes_hash[key] = { old: old_value, new: new_value } if old_value != new_value
          end.tap { |changes| return changes.empty? ? nil : changes }
        end

        # selection helpers
        def ask_to_overwrite(question)
          answer = ''
          until %w[y n].include?(answer)
            print "#{question}? (y/N): "
            answer = $stdin.gets.strip.downcase
          end
          answer == 'y'
        end

        # info helpers

        def print_changes(changes, message)
          return unless changes

          puts "#{message}:\n\n"
          changes.each do |key, diff|
            puts "#{key}: #{diff[:old]} => #{diff[:new]}"
          end
          puts "\n"
        end

        # error helpers

        def check_git_tracking_error
          puts
          puts "Error - please remove '#{fetch(:figaro_yml_local_path)}' from git:"
          puts
          puts "    $ git rm --cached #{fetch(:figaro_yml_local_path)}"
          puts
          puts 'and gitignore it:'
          puts
          puts "    $ echo '#{fetch(:figaro_yml_local_path)}' >> .gitignore"
          puts
        end

        def check_config_present_error
          puts
          puts "Error - '#{figaro_yml_env}' config not present in '#{fetch(:figaro_yml_local_path)}'."
          puts 'Please populate it.'
          puts
        end

        def check_figaro_file_exists_error
          puts
          puts "Error - '#{fetch(:figaro_yml_local_path)}' file does not exists, and it's required."
          puts
        end

        # file helpers
        def write_to_file(file, content)
          File.open(file, 'w') do |f|
            f.write(content)
          end
        end

        def write_combined_yaml(yamls_combined)
          if yamls_combined.empty?
            info 'No data to write.'
          else
            # write to new file
            info 'writing to config/application.yml'
            write_to_file(figaro_yml_local_path, yamls_combined.to_yaml)
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
