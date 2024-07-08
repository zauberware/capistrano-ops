# frozen_string_literal: true

require_relative 'figaro_yaml_helper'

namespace :figaro_yml do
  include FigaroYmlHelper

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
