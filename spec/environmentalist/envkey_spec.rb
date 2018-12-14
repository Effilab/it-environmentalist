# frozen_string_literal: true

RSpec.describe Environmentalist::Envkey do
  subject { described_class }

  describe ".fetch" do
    def stub_popen(args, output = nil)
      stub = allow(IO).to receive(:popen).with(args)
      stub.and_yield(StringIO.new(output)) if output
      stub
    end

    def stub_exit_status(exit_status)
      `exit #{exit_status}`
    end

    it "rejects blank ENVKEYs" do
      expect do
        subject.fetch(envkey: "")
      end.to raise_error(subject::Error, "ENVKEY cannot be blank")
    end

    it "wraps the envkey-fetch binary" do
      envkey = "envkey_foo"
      envkey_output = %({ "FOO": "BAR" })

      stub_popen(["envkey-fetch", envkey], envkey_output)
      stub_exit_status(0)

      expect(subject.fetch(envkey: envkey)).to eq("FOO" => "BAR")
    end

    it "knows how to cache envkey values" do
      envkey = "envkey_foo"
      envkey_output = %({ "FOO": "BAR" })

      stub_popen(["envkey-fetch", envkey, "--cache"], envkey_output)
      stub_exit_status(0)

      expect(subject.fetch(envkey: envkey, cache: true)).to eq("FOO" => "BAR")
    end

    it "handles envkey-fetch errors" do
      envkey = "envkey_foo"
      envkey_output = ""

      stub_popen(["envkey-fetch", envkey], envkey_output)
      stub_exit_status(1)

      expect do
        subject.fetch(envkey: envkey)
      end.to raise_error(subject::Error, "envkey-fetch failed")
    end

    it "handles envkey-fetch silent errors" do
      envkey = "envkey_foo"
      envkey_output = "error: invalid envkey"

      stub_popen(["envkey-fetch", envkey], envkey_output)
      stub_exit_status(0)

      expect do
        subject.fetch(envkey: envkey)
      end.to(
        output("#{envkey_output}\n").to_stderr & \
          raise_error(subject::Error, "envkey-fetch failed")
      )
    end

    it "handles envkey-fetch output errors" do
      envkey = "envkey_foo"
      envkey_output = "Something went wrong"

      stub_popen(["envkey-fetch", envkey], envkey_output)
      stub_exit_status(0)

      expect do
        subject.fetch(envkey: envkey)
      end.to raise_error(subject::Error, "envkey-fetch output is not JSON")
    end
  end
end
