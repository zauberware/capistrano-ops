# frozen_string_literal: true

namespace :figaro_yml do
  include Capistrano::Ops::FigaroYml::Paths
  include Capistrano::Ops::FigaroYml::Helpers

  desc 'Setup figaro `application.yml` file on the server(s)'
  task setup: [:check] do
    content = figaro_yml_content
    on release_roles :all do
      execute :mkdir, '-pv', File.dirname(figaro_yml_remote_path)
      upload! StringIO.new(content), figaro_yml_remote_path
    end
  end
  before 'figaro_yml:setup', 'figaro_yml:backup'
end
