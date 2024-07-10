# frozen_string_literal: true

namespace :logs do
  include Capistrano::Ops::Logs::Paths
  include Capistrano::Ops::Logs::Helpers

  desc 'Tail Rails logs'
  task :rails do
    on roles(fetch(:rake_roles, :app)) do
      trap_interrupt

      execute "tail -f #{rails_log_file_path}" do |_channel, stream, data|
        puts data
        break if stream == :err
      end
    end
  end
end
