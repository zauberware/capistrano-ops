# frozen_string_literal: true

module Capistrano
  module Ops
    module Helper
      def binary_path
        gem_path = capture(:bundle, 'show', 'wkhtmltopdf-binary').strip
        "#{gem_path}/bin"
      end

      def gem_version
        capture(:cat, 'config/initializers/wicked_pdf.rb').scan(/wkhtmltopdf_ubuntu_(\d+\.\d+)_amd64/).flatten.first
      end

      def binary_path_and_version
        [binary_path, gem_version]
      end

      def file_existing?(file)
        test("[ -f #{file} ]")
      end

      def right_permissions?(file)
        test("[ $(stat -c '%a' #{file}) = '777' ]")
      end

      def check_file_and_permissions(binary_path, version)
        binary_file = "#{binary_path}/wkhtmltopdf_ubuntu_#{version}_amd64"

        if file_existing?(binary_file)
          info('wkhtmltopdf binary already extracted')

          if right_permissions?(binary_file)
            info('wkhtmltopdf binary has already the right permissions')
          else
            info('adding right permissions to wkhtmltopdf binary')
            execute("chmod 777 #{binary_file}")
          end
        else
          info('extracting wkhtmltopdf binary')
          # extract the binary but keep the gzip file
          execute("cd #{binary_path} && gzip -dk  wkhtmltopdf_ubuntu_#{version}_amd64.gz")
          # add execute permission to the binary
          execute("chmod 777 #{binary_file}")
        end
        info('wkhtmltopdf setup finished')
      end
    end
  end
end
