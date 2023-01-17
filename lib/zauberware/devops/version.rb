# frozen_string_literal: true
module Zauberware
  require 'git-version-bump'
  module DevOps
    VERSION = GVB.version.strip.gsub(/(?<=[0-9]\.[0-9]\.[0-9])(\..+)/, '')
  end
end
