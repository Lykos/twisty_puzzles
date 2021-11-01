# frozen_string_literal: true

describe PureCommutator do
  let(:commutator) { parse_commutator('[R, U\' L\' U]') }
  let(:no_brackets_commutator) { parse_commutator('R, U\' L\' U') }
  let(:no_brackets_slash_commutator) { parse_commutator('[R/U\' L\' U]') }
  let(:slash_commutator) { parse_commutator('R/U\' L\' U') }

  it 'is equal to its variant without brackets' do
    expect(commutator).to eq(no_brackets_commutator)
  end

  it 'is equal to its variant without brackets with slash' do
    expect(commutator).to eq(no_brackets_slash_commutator)
  end

  it 'is equal to its variant with slash' do
    expect(commutator).to eq(slash_commutator)
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

describe SetupCommutator do
  let(:commutator) { parse_commutator('[U\' : [R, U\' L\' U]]') }
  let(:no_inner_brackets_commutator) { parse_commutator('[U\' : R, U\' L\' U]') }
  let(:no_inner_brackets_slash_commutator) { parse_commutator('[U\' : R/ U\' L\' U]') }
  let(:no_outer_brackets_commutator) { parse_commutator('U\' : [R, U\' L\' U]') }
  let(:no_outer_brackets_slash_commutator) { parse_commutator('U\' : [R/ U\' L\' U]') }
  let(:no_brackets_commutator) { parse_commutator('U\' : R, U\' L\' U') }
  let(:no_brackets_slash_commutator) { parse_commutator('U\' : R / U\' L\' U') }
  let(:slash_commutator) { parse_commutator('U\' : R, U\' L\' U') }
  let(:rotation_commutator) { parse_commutator('[x2 : [R, U\' L\' U]]') }

  it 'is equal to its variant without brackets and with slash' do
    expect(commutator).to eq(no_brackets_slash_commutator)
  end

  it 'is equal to its variant with slash' do
    expect(commutator).to eq(slash_commutator)
  end

  it 'is equal to its variant without outer brackets' do
    expect(commutator).to eq(no_outer_brackets_commutator)
  end

  it 'is equal to its variant without outer brackets with slash' do
    expect(commutator).to eq(no_outer_brackets_slash_commutator)
  end

  it 'is equal to its variant without inner brackets' do
    expect(commutator).to eq(no_inner_brackets_commutator)
  end

  it 'is equal to its variant without inner brackets with slash' do
    expect(commutator).to eq(no_inner_brackets_slash_commutator)
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
