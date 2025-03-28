# frozen_string_literal: true

namespace :logs do
  include Capistrano::Ops::Logs::Paths
  include Capistrano::Ops::Logs::Helpers

  desc 'Tail Nginx access logs'
  task 'nginx:info' do
    on roles(fetch(:rake_roles, :app)) do
      trap_interrupt

      execute "tail -f #{nginx_log_file_path}" do |_channel, stream, data|
        puts data
        break if stream == :err
      end
    end
  end

  desc 'Tail Nginx error logs'
  task 'nginx:errors' do
    on roles(fetch(:rake_roles, :app)) do
      trap_interrupt

      execute "tail -f #{nginx_error_log_file_path}" do |_channel, stream, data|
        puts data
        break if stream == :err
      end
    end
  end

  desc 'Tail all Nginx logs'
  task :nginx do
    on roles(fetch(:rake_roles, :app)) do
      trap_interrupt

      execute "tail -f #{nginx_log_file_path} & tail -f #{nginx_error_log_file_path}" do |_channel, stream, data|
        puts data
        break if stream == :err
      end
    end
  end
end
