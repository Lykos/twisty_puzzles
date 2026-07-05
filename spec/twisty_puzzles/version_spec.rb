# frozen_string_literal: true

describe TwistyPuzzles do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
    expect(described_class::VERSION).to be_a(String)
    expect(described_class::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end
