# frozen_string_literal: true

require "json"
require "English"

module Environmentalist
  module Envkey
    Error = Class.new(StandardError)

    class Fetch
      def call(cache: false, envkey: ENV["ENVKEY"])
        check_envkey(envkey)

        json =
          if cache
            run_cmd(envkey, "--cache")
          else
            run_cmd(envkey)
          end

        parse_output(json)
      end

      private

      def check_envkey(envkey)
        raise Error, "ENVKEY cannot be blank" if envkey.nil? || envkey.empty?
      end

      def run_cmd(envkey, *args)
        IO.popen(["envkey-fetch", envkey, *args], &:read).chomp.tap do |out|
          raise Error, "envkey-fetch failed" unless $CHILD_STATUS.success?

          if out.start_with?("error: ")
            warn(out)
            raise Error, "envkey-fetch failed"
          end
        end
      end

      def parse_output(json)
        JSON.parse(json)
      rescue JSON::ParserError
        raise Error, "envkey-fetch output is not JSON"
      end
    end

    private_constant :Fetch

    @fetch = Fetch.new

    def self.fetch(*args)
      @fetch.call(*args)
    end
  end
end
