# frozen_string_literal: true

namespace :wkhtmltopdf do
  include Capistrano::Ops::Wkhtmltopdf::Helpers
  after 'deploy:symlink:release', 'wkhtmltopdf:setup'

  desc 'unzip wkhtmltopdf if necessary'
  task :setup do
    on roles(:app) do
      within release_path do
        binary_path, version = binary_path_and_version
        info("setup wkhtmltopdf version #{version}")
        check_file_and_permissions(binary_path, version)
      end
    end
  end
end
