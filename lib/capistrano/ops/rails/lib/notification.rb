# frozen_string_literal: true

require 'capistrano/ops/rails/lib/notification/api'
require 'capistrano/ops/rails/lib/notification/slack'
require 'capistrano/ops/rails/lib/notification/webhook'

module Notification
  class Error < StandardError; end
end
