# frozen_string_literal: true

namespace :invoke do
  # Defalut to :app roles
  rake_roles = fetch(:rake_roles, :app)

  desc 'Execute a rake task on a remote server (cap invoke:rake TASK=db:migrate)'
  task :rake do
    task_name = ENV['TASK']
    unless task_name
      puts "\n\nFailed! You need to specify the 'TASK' parameter!",
           'Usage: cap <stage> invoke:rake TASK=your:task',
           'Example: cap production invoke:rake TASK=db:migrate'
      exit 1
    end

    on roles(rake_roles) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, task_name
        end
      end
    end
  end
end
