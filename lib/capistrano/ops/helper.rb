# frozen_string_literal: true

module Capistrano
  module Ops
    module Helper
      def gem_in_gemfile?(gem_name)
        return false unless File.exist?('Gemfile')

        regex = Regexp.new("^\s*gem\s+['\"]#{gem_name}['\"].*?(?=#|$)", Regexp::MULTILINE)
        File.read('Gemfile').match?(regex)
      end
    end
  end
end
