require 'capistrano/ops/backup/api'
require 'capistrano/ops/backup/s3'


module Backup
    class Error < StandardError; end
end