# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :figaro_yml do
  # Defaults to :app role
  rake_roles = fetch(:rake_roles, :app)

  desc 'get the `application.yml` file from server and create local if it does not exist'
  task :get do
    env = fetch(:stage)
    if !File.exist?('config/application.yml')
      puts 'config/application.yml does not exist, creating it from all stages'
      run_locally do
        yamls = {}
        stages = Dir.glob('config/deploy/*.rb')
        puts "found #{stages.count} stages"
        stages.map do |f|
          stage = File.basename(f, '.rb')
          puts "download #{stage} application.yml"
          begin
            res = capture "cap #{stage} figaro_yml:get_stage"
            yamls = yamls.merge(YAML.safe_load(res))
          rescue StandardError
            puts "could not get #{stage} application.yml"
          end
          yamls
        end
        # write to new file
        puts 'writing to config/application.yml'
        write_to_file('config/application.yml', yamls.to_yaml)
      end
    else
      local_yml = YAML.safe_load(File.read('config/application.yml'))
      on roles(rake_roles) do
        remote = capture("cat #{shared_path}/config/application.yml")
        remote_yml = YAML.safe_load(remote)
        remote_stage = remote_yml[env.to_s]
        puts "remote application.yml stage '#{env}':\n\n"
        puts "#{remote}\r\n"
        puts "\r\n"
        loop do
          print "Overwrite local application.yml stage '#{env}'? (y/N): "
          input = $stdin.gets.strip.downcase
          answer = (input.empty? ? 'N' : input).downcase.to_s

          next unless %w[y n].include?(answer)

          if answer == 'y'
            puts 'Updating local application.yml'
            local_yml[env.to_s] = remote_stage
            write_to_file('config/application.yml', local_yml.to_yaml)
            exit
          end
          break
        end
        puts 'Nothing written to local application.yml'
        exit
      end
    end
  end

  task :get_stage do
    on roles(rake_roles) do
      puts capture "cat #{shared_path}/config/application.yml"
    end
  end

  desc 'compare and set the figaro_yml file on the server'
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

          next unless %w[y n].include?(answer)

          if answer == 'y'
            puts 'Updating remote application.yml'
            invoke 'figaro_yml:setup'
            exit
          end
          break
        end
        puts 'remote application.yml not updated'
        exit
      end
      puts 'remote application.yml is up to date'
    end
  end
  def compare_hashes(hash1, hash2)
    changes = false
    local_server = hash1.to_a - hash2.to_a
    server_local = hash2.to_a - hash1.to_a

    [local_server + server_local].flatten(1).to_h.each_key do |k|
      new_value = hash1[k].to_s
      new_value = new_value.empty? ? 'nil' : new_value
      old_value = hash2[k].to_s
      old_value = old_value.empty? ? 'nil' : old_value

      if old_value != new_value
        puts "#{k}: #{old_value} => #{new_value} \r\n"
        changes = true
      end
    end
  end

  def write_to_file(file, content)
    File.open(file, 'w') do |f|
      f.write(content)
    end
  end
end
# rubocop:enable Metrics/BlockLength
