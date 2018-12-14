# frozen_string_literal: true

RSpec.describe Environmentalist do
  subject { described_class }

  it "has a version number" do
    expect(subject::VERSION).to be_a(String) & satisfy { |obj| obj.size.positive? }
  end

  it "can register and apply transformations" do
    dummy = subject.dup
    dummy.register_transform { |k, v| "#{k}-#{v}" }
    dummy.register_transform { |_, v| "transform => #{v}" }

    expect(dummy.transform("foo", "bar")).to eq("transform => foo-bar")
  end

  it "can setup an ENV-like value" do
    env = double
    key = double
    value = double
    transformed_value = double

    allow(subject::Setup).to receive(:call).with(env) do |&block|
      { key => block.call(key, value) }
    end

    allow(subject).to receive(:transform).with(key, value).and_return(transformed_value)

    expect(subject.setup(env)).to eq(key => transformed_value)
  end
end
