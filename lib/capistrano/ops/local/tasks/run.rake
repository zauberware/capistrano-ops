# frozen_string_literal: true

namespace :local do
  include Capistrano::Ops::Local::Helpers

  desc 'Run a local script on remote via rails runner: cap <stage> local:run SCRIPT=<filename>'
  task :run do
    script = ENV.fetch('SCRIPT', nil)
    abort_script_not_given('run') unless script

    script_path = resolve_script(script)
    abort_script_not_found(script) unless script_path

    stage = fetch(:stage).to_s
    puts "\n#{color('Script:', :bold)}  #{File.basename(script_path)}"
    puts "#{color('Target:', :bold)}  #{stage}"

    confirm_dangerous_stage!('Running script')

    on roles(fetch(:console_role, :app)) do
      remote_tmp = remote_tmp_path(script_path)

      begin
        upload! script_path, remote_tmp
        puts "#{color("▶ Running #{File.basename(script_path)} on #{stage}…", :cyan)}\n\n"

        within current_path do
          with rails_env: fetch(:console_env, fetch(:rails_env, fetch(:stage))) do
            execute :bundle, :exec, :rails, 'runner', remote_tmp
          end
        end
      ensure
        execute :rm, '-f', remote_tmp
        puts color("\u{1F9F9} Cleaned up temp file on server", :dim)
      end
    end

    puts "\n#{color('✔ Done.', :green)}"
  end
end
