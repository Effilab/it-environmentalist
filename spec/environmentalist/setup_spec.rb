# frozen_string_literal: true

RSpec.describe Environmentalist::Setup do
  subject { described_class }

  def stub_env_files(env, env_pairs)
    allow(Environmentalist::EnvFile).to receive(:find_and_parse).with(env) do |&block|
      env_pairs.each(&block)
    end
  end

  def stub_envkey(opts, result)
    allow(Environmentalist::Envkey).to receive(:fetch).with(opts).and_return(result)
  end

  it "setups an ENV-like value" do
    env = {}

    stub_env_files(env, "ENVKEY" => "envkey_foo")
    stub_envkey({ envkey: "envkey_foo", cache: true }, "FOO" => "BAR")

    subject.call(env)

    expect(env).to eq(
      "RACK_ENV" => "development",
      "RAILS_ENV" => "development",
      "RELEASE_ENV" => "development",
      "ENVKEY" => "envkey_foo",
      "FOO" => "BAR"
    )
  end

  it "warns about inconsistencies in the input" do
    env = {
      "RAILS_ENV" => "development",
      "RACK_ENV" => "production",
    }

    expect do
      subject.call(env)
    end.to raise_error(/ENV inconsistency/)
  end
end
