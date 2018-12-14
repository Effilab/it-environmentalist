# frozen_string_literal: true

# This file is required after `spec_helper` and before `environmentalist`.
# See .rspec

if ENV["COVERAGE"] == "true"
  require "simplecov"

  SimpleCov.start do
    refuse_coverage_drop
  end
end
