require 'capistrano/ops/rails/lib/backup/api'
require 'capistrano/ops/rails/lib/backup/s3'

module Backup
  class Error < StandardError; end
end
