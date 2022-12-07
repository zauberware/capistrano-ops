# frozen_string_literal: true

require 'zauberware/devops'
require 'rails'
module Zauberware
  module DevOps
    class Railtie < Rails::Railtie
      railtie_name :devops
      rake_tasks do
        path = File.expand_path(__dir__)
        Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
      end
    end
  end
end