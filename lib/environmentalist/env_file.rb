# frozen_string_literal: true

module Environmentalist
  class EnvFile
    def self.find(env)
      root = env.fetch("APP_PATH", Dir.pwd)
      rails_env = env.fetch("RAILS_ENV")
      dockerized = env.fetch("DOCKERIZED", "false") == "true"

      env_files = []
      env_files << File.join(root, ".env.#{rails_env}.local")
      env_files << File.join(root, ".env.#{rails_env}")
      env_files << File.join(root, ".env.host") unless dockerized
      env_files << File.join(root, ".env")

      env_files
    end

    def self.parse(path)
      return unless File.exist?(path)

      IO.foreach(path) do |line|
        next if line.match?(/^\s*\#/)

        line.lstrip!

        key, value = line.match(/^([A-Za-z][A-Za-z0-9_]*)=(.*)$/)&.captures
        next unless key

        yield(key, value)
      end
    end

    def self.find_and_parse(env)
      find(env).each { |path| parse(path) { |k, v| yield(k, v) } }
    end
  end
end
