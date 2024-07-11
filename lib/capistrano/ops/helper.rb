module Capistrano
  module Ops
    module Helper
      def gem_in_gemfile?(gem_name)
        if File.exist?('Gemfile')
          File.foreach('Gemfile') do |line|
            return true if line.include?('gem') && line.include?("'#{gem_name}'") && !line.include?('#')
          end
        end
        false
      end
    end
  end
end
