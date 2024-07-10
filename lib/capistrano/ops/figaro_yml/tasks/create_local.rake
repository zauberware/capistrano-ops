# frozen_string_literal: true

namespace :figaro_yml do
  include Capistrano::Ops::FigaroYml::Paths
  include Capistrano::Ops::FigaroYml::Helpers
  task :create_local do
    run_locally do
      puts "found #{stages.count} stages"
      yamls_combined = {}

      stages.each do |f|
        stage = File.basename(f, '.rb')
        puts "download #{stage} application.yml"
        begin
          res = capture "cap #{stage} figaro_yml:get_stage"
          stage_yaml = YAML.safe_load(res)
          stage_yaml[stage.to_s] = stage_yaml[stage.to_s].sort.to_h
          yamls_combined.merge!(stage_yaml) if stage_yaml
        rescue StandardError
          puts "could not get #{stage} application.yml"
        end
      end

      write_combined_yaml(yamls_combined.sort.to_h)
    end
  end
end
