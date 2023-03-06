require 'capistrano/ops/notification/api'
require 'capistrano/ops/notification/slack'
require 'capistrano/ops/notification/webhook'

module Notification
    class Error < StandardError; end
end