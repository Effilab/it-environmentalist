# frozen_string_literal: true

RSpec.describe Environmentalist::EnvFile do
  subject { described_class }

  describe ".find" do
    it "lists the paths of applicable env files" do
      env = {
        "APP_PATH" => "/foo/bar/baz",
        "RAILS_ENV" => "production",
        "DOCKERIZED" => "false",
      }

      expected_paths = [
        "/foo/bar/baz/.env.production.local",
        "/foo/bar/baz/.env.production",
        "/foo/bar/baz/.env.host",
        "/foo/bar/baz/.env",
      ]

      expect(subject.find(env)).to eq(expected_paths)
    end
  end

  describe ".parse" do
    let(:path) { double }

    def stub_io_foreach(path, lines)
      allow(File).to receive(:exist?).with(path).and_return(true)

      io_foreach = allow(IO).to(receive(:foreach).with(path))

      lines.each do |line|
        io_foreach = io_foreach.and_yield(line)
      end

      io_foreach
    end

    it "yields valid (key, value) pairs" do
      stub_io_foreach(
        path, [
          +"		FOO=BAR",
          +"# this is a comment",
          +"74FO=FOO",
          +"FOO_404_zeofij_=OK",
          +"FOI=",
          +"FOFIOR",
        ]
      )

      expect do |b|
        subject.parse(path, &b)
      end.to yield_successive_args(
        ["FOO", "BAR"],
        ["FOO_404_zeofij_", "OK"],
        ["FOI", ""],
      )
    end
  end

  describe ".find_and_parse" do
    def stub_find(env, paths)
      allow(subject).to receive(:find).with(env).and_return(paths)
    end

    def stub_parse(env_files)
      env_files.each do |path, pairs|
        stub = allow(subject).to receive(:parse).with(path)

        pairs.each do |(k, v)|
          stub = stub.and_yield(k, v)
        end
      end
    end

    it "finds and parses files" do
      env = double

      env_files = {
        "path0" => [["key0", "value0"]],
        "path1" => [["key1", "value1"]],
      }

      env_pairs = env_files.values.reduce(&:+)

      stub_find(env, env_files.keys)
      stub_parse(env_files)

      expect do |b|
        subject.find_and_parse(env, &b)
      end.to yield_successive_args(*env_pairs)
    end
  end
end
