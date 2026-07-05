# frozen_string_literal: true

describe StickerCycleFactory do
  let(:cube_size) { 3 }
  let(:incarnation_index) { 0 }
  let(:factory) { described_class.new(cube_size, incarnation_index) }
  let(:corner1) { Corner.for_face_symbols(%i[U F R]) }
  let(:corner2) { Corner.for_face_symbols(%i[U R B]) }
  let(:corner3) { Corner.for_face_symbols(%i[U B L]) }
  let(:edge1) { Edge.for_face_symbols(%i[U F]) }
  let(:edge2) { Edge.for_face_symbols(%i[U R]) }

  it 'validates constructor arguments' do
    expect { described_class.new(1, 0) }.to raise_error(ArgumentError)
    expect { described_class.new(3, -1) }.to raise_error(ArgumentError)
    expect { described_class.new(3, :invalid) }.to raise_error(ArgumentError)
  end

  it 'returns coordinates correctly' do
    coords = factory.coordinates(corner1)
    expect(coords).to be_an(Array)
    expect(coords.first).to be_a(Coordinate)
    # Check cache works (returns identical array object)
    expect(factory.coordinates(corner1).object_id).to eq(coords.object_id)
  end

  it 'supports multi_twist' do
    twist = factory.multi_twist([corner1, corner2])
    expect(twist).to be_a(StickerCycles)
    expect(twist.cube_size).to eq(cube_size)
    expect(twist.sticker_cycles.length).to eq(2)
  end

  it 'raises TypeError on invalid multi_twist parts' do
    center = XCenter.for_face_symbols(%i[U R F])
    expect { factory.multi_twist([center]) }.to raise_error(TypeError)
  end

  it 'raises ArgumentError on cycles of length smaller than 2' do
    expect { factory.construct([corner1]) }.to raise_error(ArgumentError)
  end

  it 'raises ArgumentError on unsupported incarnation index' do
    invalid_factory = described_class.new(cube_size, 100)
    expect { invalid_factory.construct([corner1, corner2]) }.to raise_error(ArgumentError)
  end

  it 'raises TypeError on heterogenous piece types' do
    expect { factory.construct([corner1, edge1]) }.to raise_error(TypeError)
  end

  it 'constructs sticker cycles correctly' do
    cycles = factory.construct([corner1, corner2, corner3])
    expect(cycles).to be_a(StickerCycles)
    expect(cycles.cube_size).to eq(cube_size)
    expect(cycles.sticker_cycles.length).to eq(3) # corners have 3 coordinates (stickers)
  end
end
