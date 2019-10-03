# frozen_string_literal: true

require "pathname"

root_path = Pathname.new(__dir__)

Gem::Specification.new do |spec|
  spec.name          = "environmentalist"
  spec.version       = root_path.join("VERSION").read.strip
  spec.author        = "Effilab"

  spec.summary       = %(Environment setup for Effilab IT applications)
  spec.homepage      = %(https://github.com/effilab/it-environmentalist)

  # Prevent pushing this gem to RubyGems.org.
  spec.metadata["allowed_push_host"] = ""

  # Specify which files should be added to the gem when it is released.
  spec.files = [
    root_path.join("VERSION"),
    *root_path.glob("exe/*"),
    *root_path.glob("lib/**/*"),
  ].map!(&:to_s)

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.8"
  spec.add_development_dependency "rspec_junit_formatter", "~> 0.4"
  spec.add_development_dependency "rubocop", "~> 0.61"
  spec.add_development_dependency "rubocop-rspec", "~> 1.30"
  spec.add_development_dependency "simplecov", "~> 0.16"
end
