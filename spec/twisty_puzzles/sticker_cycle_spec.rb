# frozen_string_literal: true

describe StickerCycle do
  let(:cube_size) { 3 }
  let(:c1) { Coordinate.from_indices(Face::U, cube_size, 0, 0) }
  let(:c2) { Coordinate.from_indices(Face::U, cube_size, 0, 1) }
  let(:c3) { Coordinate.from_indices(Face::U, cube_size, 0, 2) }
  let(:cycle) { described_class.from_coordinates(cube_size, [c1, c2]) }

  it 'validates inputs in from_coordinates' do
    expect { described_class.from_coordinates(1, [c1, c2]) }.to raise_error(ArgumentError)
    expect { described_class.from_coordinates(cube_size, [c1, :invalid]) }.to raise_error(TypeError)
  end

  it 'validates native type in constructor' do
    expect { described_class.new(:invalid) }.to raise_error(TypeError)
  end

  it 'exposes details correctly' do
    expect(cycle.cube_size).to eq(cube_size)
    expect(cycle.length).to eq(2)
    expect(cycle.native).to be_a(Native::StickerCycle)
  end

  it 'compares and hashes correctly' do
    cycle2 = described_class.from_coordinates(cube_size, [c1, c2])
    cycle3 = described_class.from_coordinates(cube_size, [c1, c3])
    expect(cycle).to eq(cycle2)
    expect(cycle).not_to eq(cycle3)
    expect(cycle.hash).to eq(cycle2.hash)
  end

  it 'returns its inverse' do
    inv = cycle.inverse
    expect(inv.length).to eq(2)
    expect(inv.inverse).to eq(cycle)
  end

  it 'validates apply_to argument' do
    expect { cycle.apply_to(:invalid) }.to raise_error(TypeError)
  end

  it 'applies to a cube state' do
    state = ColorScheme::WCA.solved_cube_state(cube_size)
    state[c1]
    state[c2]
    # Set different colors to tell them apart
    state[c1] = :red
    state[c2] = :blue

    cycle.apply_to(state)
    expect(state[c1]).to eq(:blue)
    expect(state[c2]).to eq(:red)
  end
end

describe StickerCycles do
  let(:cube_size) { 3 }
  let(:c1) { Coordinate.from_indices(Face::U, cube_size, 0, 0) }
  let(:c2) { Coordinate.from_indices(Face::U, cube_size, 0, 1) }
  let(:c3) { Coordinate.from_indices(Face::U, cube_size, 0, 2) }
  let(:c4) { Coordinate.from_indices(Face::U, cube_size, 1, 0) }

  let(:cycle1) { StickerCycle.from_coordinates(cube_size, [c1, c2]) }
  let(:cycle2) { StickerCycle.from_coordinates(cube_size, [c3, c4]) }
  let(:intersecting_cycle) { StickerCycle.from_coordinates(cube_size, [c2, c3]) }

  let(:cycles) { described_class.new(cube_size, [cycle1, cycle2]) }

  it 'raises TypeError on invalid constructor elements' do
    expect { described_class.new(cube_size, [cycle1, :invalid]) }.to raise_error(TypeError)
  end

  it 'raises ArgumentError on intersecting cycles' do
    expect { described_class.new(cube_size, [cycle1, intersecting_cycle]) }.to raise_error(ArgumentError)
  end

  it 'exposes details correctly' do
    expect(cycles.cube_size).to eq(cube_size)
    expect(cycles.sticker_cycles).to eq([cycle1, cycle2])
  end

  it 'supports addition' do
    part1 = described_class.new(cube_size, [cycle1])
    part2 = described_class.new(cube_size, [cycle2])
    sum = part1 + part2
    expect(sum.sticker_cycles).to eq([cycle1, cycle2])

    expect { part1 + :invalid }.to raise_error(TypeError)
    expect { part1 + described_class.new(4, []) }.to raise_error(ArgumentError)
  end

  it 'returns its inverse' do
    inv = cycles.inverse
    expect(inv.sticker_cycles.map(&:inverse)).to eq(cycles.sticker_cycles)
  end

  it 'applies to a cube state' do
    state = ColorScheme::WCA.solved_cube_state(cube_size)
    expect { cycles.apply_to(:invalid) }.to raise_error(TypeError)
    expect { cycles.apply_to(ColorScheme::WCA.solved_cube_state(4)) }.to raise_error(ArgumentError)

    state[c1] = :red
    state[c2] = :blue
    cycles.apply_to(state)
    expect(state[c1]).to eq(:blue)
    expect(state[c2]).to eq(:red)
  end
end
