# frozen_string_literal: true

namespace :figaro_yml do
  include Capistrano::Ops::FigaroYml::Paths
  include Capistrano::Ops::FigaroYml::Helpers
  task :sort_local do
    run_locally do
      info 'Sorting local application.yml...'
      local = local_yaml
      sorted_local = sort_with_nested(local)
      write_combined_yaml(sorted_local)
    end
  end

  task :sort do
    invoke 'figaro_yml:sort_local'
  end
end
