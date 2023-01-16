# frozen_string_literal: true
module Zauberware
  require 'git-version-bump'
  module DevOps
    VERSION = GVB.version
  end
end
