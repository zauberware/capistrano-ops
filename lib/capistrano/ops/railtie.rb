# frozen_string_literal: true

require 'capistrano/ops'
require 'rails'
module Capistrano
  module Ops
    class Railtie < Rails::Railtie
      railtie_name :ops
      rake_tasks do
        path = File.expand_path(__dir__)
        Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
      end
    end
  end
end