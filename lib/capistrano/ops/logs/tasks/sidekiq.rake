# frozen_string_literal: true

namespace :logs do
  include Capistrano::Ops::Logs::Paths
  include Capistrano::Ops::Logs::Helpers

  desc 'Tail Rails info logs'
  task 'sidekiq:info' do
    on roles(fetch(:rake_roles, :app)) do
      trap_interrupt

      execute "tail -f #{sidekiq_log_file_path}" do |_channel, stream, data|
        puts data
        break if stream == :err
      end
    end
  end

  desc 'Tail Sidekiq error logs'
  task 'sidekiq:errors' do
    on roles(fetch(:rake_roles, :app)) do
      trap_interrupt

      execute "tail -f #{sidekiq_error_log_file_path}" do |_channel, stream, data|
        puts data
        break if stream == :err
      end
    end
  end

  desc 'Tail all Sidekiq logs'
  task :sidekiq do
    on roles(fetch(:rake_roles, :app)) do
      trap_interrupt

      execute "tail -f #{sidekiq_log_file_path} & tail -f #{sidekiq_error_log_file_path}" do |_channel, stream, data|
        puts data
        break if stream == :err
      end
    end
  end
end
