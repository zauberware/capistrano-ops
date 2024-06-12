# frozen_string_literal: true

namespace :wkhtmltopdf do
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
def binary_path_and_version
  # get the binary path of wkhtmltopdf-binary
  gem_path = capture(:bundle, 'show', 'wkhtmltopdf-binary').strip
  binary_path = "#{gem_path}/bin"

  # get the use wkhtmltopdf_ubuntu version from the wicked_pdf initializer
  version = capture(:cat, 'config/initializers/wicked_pdf.rb').scan(/wkhtmltopdf_ubuntu_(\d+\.\d+)_amd64/).flatten.first

  [binary_path, version]
end

def check_file_and_permissions(binary_path, version)
  binary_file = "#{binary_path}/wkhtmltopdf_ubuntu_#{version}_amd64"

  if test("[ -f #{binary_file} ]")
    info('wkhtmltopdf binary already extracted')

    if test("[ $(stat -c '%a' #{binary_file}) = '777' ]")
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
