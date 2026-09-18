# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Capistrano::Ops do
  it 'has a version number' do
    expect(Capistrano::Ops::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end
