# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :figaro_yml do
  # Defaults to :app role
  rake_roles = fetch(:rake_roles, :app)

  desc 'get the figaro_yml file from the server'
  task :get do
    on roles(rake_roles) do
      puts capture "cat #{shared_path}/config/application.yml"
    end
  end

  task :compare do
    env = fetch(:stage)
    # read local application.yml
    local = File.read('config/application.yml')

    # convert to hash
    local_global_env = YAML.safe_load(local)

    # split into stage and global
    local_stage_env = local_global_env[env.to_s]
    local_global_env.delete('staging')
    local_global_env.delete('production')

    on roles(rake_roles) do
      # read remote application.yml
      remote = capture("cat #{shared_path}/config/application.yml")

      remote_global_env = YAML.safe_load(remote)
      remote_stage_env = remote_global_env[env.to_s]
      remote_global_env.delete(env.to_s)

      puts "with command 'cap #{env} figaro_yml:setup', following variables will be overwritten:"
      puts '--------------------------------------------------------------------------------'
      result1 = compare_hashes(local_global_env, remote_global_env)
      result2 = compare_hashes(local_stage_env, remote_stage_env)
      if !result1.empty? || !result2.empty?
        loop do
          print 'Update remote application.yml? (y/N): '
          input = $stdin.gets.strip.downcase

          answer = (input.empty? ? 'N' : input).downcase.to_s
          break if %w[y n].include?(answer)
        end

        if input == 'y'
          puts 'Updating remote application.yml'
          invoke 'figaro_yml:setup'
          exit
        end
        puts 'remote application.yml not updated'
        exit
      end
      puts 'remote application.yml is up to date'
    end
  end
  # rubocop:disable Metrics/MethodLength
  def compare_hashes(hash1, hash2)
    changes = false
    (hash1.to_a - hash2.to_a).to_h.each_key do |k|
      new_value = hash1[k].to_s
      new_value = new_value.empty? ? 'nil' : new_value
      old_value = hash2[k].to_s
      old_value = old_value.empty? ? 'nil' : old_value
      if new_value != old_value
        puts "#{k}: #{old_value} => #{new_value} \r\n"
        changes = true
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
end
# rubocop:enable Metrics/BlockLength
