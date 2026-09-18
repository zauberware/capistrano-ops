# frozen_string_literal: true

namespace :local do
  include Capistrano::Ops::Local::Helpers

  desc 'Rails console with a local script pre-loaded: cap <stage> local:console SCRIPT=<filename>'
  task :console do
    script = ENV.fetch('SCRIPT', nil)
    abort_script_not_given('console') unless script

    script_path = resolve_script(script)
    abort_script_not_found(script) unless script_path

    stage = fetch(:stage).to_s
    puts "\n#{color('Script:', :bold)}  #{File.basename(script_path)}"
    puts "#{color('Target:', :bold)}  #{stage} (interactive console)"

    confirm_dangerous_stage!('Opening console')

    remote_tmp = remote_tmp_path(script_path)
    remote_irbrc = "/tmp/cap_local_irbrc_#{SecureRandom.hex(6)}.rb"

    on primary(fetch(:console_role, :app)) do
      upload! script_path, remote_tmp
      wrapper = <<~RUBY
        load '#{remote_tmp}'
        at_exit do
          deleted = []
          begin; File.delete('#{remote_tmp}'); deleted << '#{File.basename(remote_tmp)}'; rescue StandardError; end
          begin; File.delete('#{remote_irbrc}'); deleted << 'irbrc wrapper'; rescue StandardError; end
          puts "\u{1F9F9} Cleaned up \#{deleted.size} temp file(s)" unless deleted.empty?
        end
      RUBY
      upload! StringIO.new(wrapper), remote_irbrc
    end

    puts "#{color("▶ Opening console with #{File.basename(script_path)} on #{stage}…", :cyan)}\n\n"

    run_interactively primary(fetch(:console_role, :app)), shell: fetch(:console_shell, nil) do
      within current_path do
        as user: fetch(:console_user, nil) do
          args = ['-e', fetch(:console_env, fetch(:rails_env, fetch(:stage)))]
          args.push('--', '-r', remote_irbrc)
          execute(:rails, :console, *args)
        end
      end
    end
  end
end
