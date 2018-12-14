# frozen_string_literal: true

# Configure the environmnent
# ==========================
#
# This file should be free of any reference to Rails or any other dependency
# that is not strictly required to configure the Ruby process environment.
#
# Environment variables may be loaded in three different ways (by decreasing
# order of priority):
#
# 1. from the process environment
# 2. from .env* files (if the release is local)
# 3. from the remote secrets store (envkey) (if the ENVKEY variable is set)

require_relative "env_file"
require_relative "envkey"

module Environmentalist
  class Setup
    def self.call(env = {}, &block)
      setup = new

      setup.load_environments(env)

      # .env files may be used in development, as an alternative to the
      # environment features provided by Docker for those who don't want
      # to use Docker in development.
      if env.fetch("RELEASE_ENV").match?(/development|test/)
        setup.load_env_files(env, &block)
      end

      if env.key?("ENVKEY")
        setup.load_envkey(env, cache: env["RAILS_ENV"] != "production", &block)
      end

      env
    end

    def load_environments(env)
      rails_env   = env["RAILS_ENV"]
      rack_env    = env["RACK_ENV"]
      release_env = env["RELEASE_ENV"]

      env["RAILS_ENV"]  = rails_env = "development"     if blank?(rails_env)
      env["RACK_ENV"]   = rack_env  = env["RAILS_ENV"]  if blank?(rack_env)

      if rack_env != rails_env
        raise "ENV inconsistency: RAILS_ENV=#{rails_env} RACK_ENV=#{rack_env}"
      end

      env["RELEASE_ENV"] = "development" if blank?(release_env)

      env
    end

    # Kinda copy dotenv-rails behavior (don't keep the tricky ".env.local" file
    # behavior, and don't do other than those substitutions set on the
    # environmentalist). Also, add a way to load variables only when the
    # process is running outside a container.
    def load_env_files(env, force: false)
      EnvFile.find_and_parse(env) do |key, value|
        next if env.key?(key) && !force

        value = yield(key, value) if block_given?
        env[key] = value
      end

      env
    end

    def load_envkey(env, force: false, **envkey_opts)
      Envkey.fetch(envkey: env["ENVKEY"], **envkey_opts).each do |key, value|
        next if env.key?(key) && !force

        value = yield(key, value) if block_given?
        env[key] = value
      end

      env
    end

    private

    def blank?(str)
      str.nil? || str.empty?
    end
  end
end
