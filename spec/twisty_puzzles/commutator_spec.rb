# frozen_string_literal: true

describe PureCommutator do
  let(:cube_size) { 3 }
  let(:commutator) { parse_commutator('[R, U\' L\' U]') }
  let(:no_brackets_commutator) { parse_commutator('R, U\' L\' U') }
  let(:like_slash_commutator) { parse_commutator('U M\' U2 M U') }
  let(:no_brackets_slash_commutator) { parse_commutator('[U/M\']') }
  let(:slash_commutator) { parse_commutator('U/M\'') }

  it 'is equal to its variant without brackets' do
    expect(commutator).to eq(no_brackets_commutator)
  end

  it 'is equal to its variant without brackets with slash' do
    expect(like_slash_commutator.algorithm.cancelled(cube_size)).to eq(no_brackets_slash_commutator.algorithm.cancelled(cube_size))
  end

  it 'is equal to its variant with slash' do
    expect(like_slash_commutator.algorithm.cancelled(cube_size)).to eq(slash_commutator.algorithm.cancelled(cube_size))
  end

  it 'is equal to the inverse of its inverse' do
    expect(commutator.inverse.inverse).to eq(commutator)
  end

  it 'is inverted appropriately' do
    expect(commutator.inverse.to_s).to eq('[U\' L\' U, R]')
  end

  it 'is printed appropriately' do
    expect(commutator.to_s).to eq('[R, U\' L\' U]')
  end
end

describe CommutatorSequence do
  let(:cube_size) { 3 }
  let(:commutator) { parse_commutator('[R, U\' L\' U] + [L, U]') }
  let(:algorithm) { parse_algorithm('R U\' L\' U R\' U\' L U L U L\' U\'') }
  let(:inverse) { parse_commutator('[U, L] + [U\' L\' U, R]') }

  it 'has the right inverse' do
    expect(commutator.inverse).to eq(inverse)
  end

  it 'has the right algorithm inverse' do
    expect(commutator.algorithm.inverse).to eq(inverse.algorithm)
  end

  it 'has the right algorithm' do
    expect(commutator.algorithm).to eq(algorithm)
  end

  it 'is printed appropriately' do
    expect(commutator.to_s).to eq('[R, U\' L\' U] + [L, U]')
  end
end

describe SetupCommutator do
  let(:commutator) { parse_commutator('[U\' : [R, U\' L\' U]]') }
  let(:cube_size) { 3 }
  let(:no_inner_brackets_commutator) { parse_commutator('[U\' : R, U\' L\' U]') }
  let(:no_outer_brackets_commutator) { parse_commutator('U\' : [R, U\' L\' U]') }
  let(:no_brackets_commutator) { parse_commutator('U\' : R, U\' L\' U') }
  let(:like_slash_commutator) { parse_commutator('[B : U M\' U2 M U]') }
  let(:no_inner_brackets_slash_commutator) { parse_commutator('[B : U/M\']') }
  let(:no_outer_brackets_slash_commutator) { parse_commutator('B : [U/M\']') }
  let(:no_brackets_slash_commutator) { parse_commutator('B : U / M\'') }
  let(:slash_commutator) { parse_commutator('B : U/M\'') }
  let(:rotation_commutator) { parse_commutator('[x2 : [R, U\' L\' U]]') }

  it 'is equal to its variant without brackets' do
    expect(commutator).to eq(no_brackets_commutator)
  end

  it 'is equal to its variant without outer brackets' do
    expect(commutator).to eq(no_outer_brackets_commutator)
  end

  it 'is equal to its variant without inner brackets' do
    expect(commutator).to eq(no_inner_brackets_commutator)
  end

  it 'is equal to its variant without outer brackets with slash' do
    expect(like_slash_commutator.algorithm.cancelled(cube_size)).to eq(no_outer_brackets_slash_commutator.algorithm.cancelled(cube_size))
  end

  it 'is equal to its variant without inner brackets with slash' do
    expect(like_slash_commutator.algorithm.cancelled(cube_size)).to eq(no_inner_brackets_slash_commutator.algorithm.cancelled(cube_size))
  end

  it 'is equal to its variant without brackets and with slash' do
    expect(like_slash_commutator.algorithm.cancelled(cube_size)).to eq(no_brackets_slash_commutator.algorithm.cancelled(cube_size))
  end

  it 'is equal to the inverse of its inverse' do
    expect(commutator.inverse.inverse).to eq(commutator)
  end

  it 'is equal to the inverse of its inverse' do
    expect(commutator.inverse.inverse).to eq(commutator)
  end

  it 'is inverted appropriately' do
    expect(commutator.inverse.to_s).to eq('[U\' : [U\' L\' U, R]]')
  end

  it 'is printed appropriately' do
    expect(commutator.to_s).to eq('[U\' : [R, U\' L\' U]]')
  end

  it 'is printed appropriately even with rotations' do
    expect(rotation_commutator.to_s).to eq('[x2 : [R, U\' L\' U]]')
  end
end

describe Commutator do
  it 'raises NotImplementedError on abstract algorithm method' do
    expect { described_class.new.algorithm }.to raise_error(NotImplementedError)
  end

  it 'delegates cancellations to algorithm' do
    subclass =
      Class.new(described_class) do
        def initialize(alg)
          super()
          @alg = alg
        end

        def algorithm
          @alg
        end
      end
    c1 = subclass.new(parse_algorithm('R'))
    c2 = subclass.new(parse_algorithm("R'"))
    expect(c1.cancellations(c2, 3)).to eq(2)
  end
end

describe FakeCommutator do
  let(:alg) { parse_algorithm('R U') }
  let(:fake) { described_class.new(alg) }

  it 'validates algorithm type on initialization' do
    expect { described_class.new(:invalid) }.to raise_error(TypeError)
  end

  it 'returns property, string representation, and inverse' do
    expect(fake.algorithm).to eq(alg)
    expect(fake.to_s).to eq('R U')
    expect(fake.inverse).to eq(described_class.new(alg.inverse))
  end

  it 'compares and hashes correctly' do
    fake2 = described_class.new(alg)
    fake3 = described_class.new(parse_algorithm('R'))
    expect(fake).to eq(fake2)
    expect(fake).not_to eq(fake3)
    expect(fake.hash).to eq(fake2.hash)
  end
end

describe PureCommutator do
  it 'validates types on initialization' do
    expect { described_class.new(:invalid, parse_algorithm('R')) }.to raise_error(TypeError)
    expect { described_class.new(parse_algorithm('R'), :invalid) }.to raise_error(TypeError)
  end
end

describe SetupCommutator do
  it 'validates types on initialization' do
    expect { described_class.new(:invalid, parse_commutator('[R, U]')) }.to raise_error(TypeError)
    expect { described_class.new(parse_algorithm('R'), :invalid) }.to raise_error(TypeError)
  end
end

describe CommutatorSequence do
  it 'validates types on initialization' do
    expect { described_class.new(:invalid) }.to raise_error(TypeError)
    expect { described_class.new([:invalid]) }.to raise_error(TypeError)
  end
end
