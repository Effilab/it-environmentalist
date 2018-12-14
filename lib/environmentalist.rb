# frozen_string_literal: true

require_relative "environmentalist/version"
require_relative "environmentalist/setup"

module Environmentalist
  @transform_callbacks = []

  def self.transform(key, value)
    @transform_callbacks.reduce(value) do |result, callback|
      callback.call(key, result)
    end
  end

  def self.register_transform(&block)
    @transform_callbacks << block
  end

  def self.setup(env = {})
    Setup.call(env) do |key, value|
      transform(key, value)
    end
  end
end
