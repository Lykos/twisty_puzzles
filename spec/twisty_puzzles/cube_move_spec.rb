# frozen_string_literal: true

describe CubeMove do
  let(:color_scheme) { ColorScheme::BERNHARD }

  it 'inverts M slices correctly' do
    expect(parse_move('M').inverse).to eq_move("M'")
    expect(parse_move("M'").inverse).to eq_move('M')
    expect(parse_move('S').inverse).to eq_move("S'")
    expect(parse_move("S'").inverse).to eq_move('S')
    expect(parse_move('E').inverse).to eq_move("E'")
    expect(parse_move("E'").inverse).to eq_move('E')
  end

  it 'recognizes equivalent fat M-slice moves' do
    expect(FatMSliceMove.new(Face::U, CubeDirection::FORWARD)).to be_equivalent(FatMSliceMove.new(Face::D, CubeDirection::BACKWARD), 3)
    expect(FatMSliceMove.new(Face::U, CubeDirection::FORWARD)).not_to be_equivalent(FatMSliceMove.new(Face::D, CubeDirection::FORWARD), 3)
    expect(FatMSliceMove.new(Face::U, CubeDirection::FORWARD)).not_to be_equivalent(FatMSliceMove.new(Face::U, CubeDirection::BACKWARD), 3)
  end

  it 'recognizes equivalent fat M-slice and slice moves' do
    expect(FatMSliceMove.new(Face::U, CubeDirection::FORWARD)).to be_equivalent(SliceMove.new(Face::U, CubeDirection::FORWARD, 1), 3)
    expect(FatMSliceMove.new(Face::U, CubeDirection::FORWARD)).to be_equivalent(SliceMove.new(Face::D, CubeDirection::BACKWARD, 1), 3)
    expect(FatMSliceMove.new(Face::U, CubeDirection::FORWARD)).not_to be_equivalent(SliceMove.new(Face::U, CubeDirection::FORWARD, 1), 4)
    expect(FatMSliceMove.new(Face::U, CubeDirection::FORWARD)).not_to be_equivalent(SliceMove.new(Face::D, CubeDirection::BACKWARD, 1), 4)
    expect(FatMSliceMove.new(Face::U, CubeDirection::FORWARD)).not_to be_equivalent(SliceMove.new(Face::D, CubeDirection::FORWARD, 1), 3)
    expect(FatMSliceMove.new(Face::U, CubeDirection::FORWARD)).not_to be_equivalent(SliceMove.new(Face::U, CubeDirection::BACKWARD, 1), 3)

    expect(SliceMove.new(Face::U, CubeDirection::FORWARD, 1)).to be_equivalent(FatMSliceMove.new(Face::U, CubeDirection::FORWARD), 3)
    expect(SliceMove.new(Face::U, CubeDirection::FORWARD, 1)).to be_equivalent(FatMSliceMove.new(Face::D, CubeDirection::BACKWARD), 3)
    expect(SliceMove.new(Face::U, CubeDirection::FORWARD, 1)).not_to be_equivalent(FatMSliceMove.new(Face::U, CubeDirection::FORWARD), 4)
    expect(SliceMove.new(Face::U, CubeDirection::FORWARD, 1)).not_to be_equivalent(FatMSliceMove.new(Face::D, CubeDirection::BACKWARD), 4)
    expect(SliceMove.new(Face::U, CubeDirection::FORWARD, 1)).not_to be_equivalent(FatMSliceMove.new(Face::D, CubeDirection::FORWARD), 3)
    expect(SliceMove.new(Face::U, CubeDirection::FORWARD, 1)).not_to be_equivalent(FatMSliceMove.new(Face::U, CubeDirection::BACKWARD), 3)
  end

  it 'recognizes equivalent slice moves' do
    expect(SliceMove.new(Face::U, CubeDirection::FORWARD, 1)).to be_equivalent(SliceMove.new(Face::D, CubeDirection::BACKWARD, 2), 4)
    expect(SliceMove.new(Face::U, CubeDirection::FORWARD, 1)).not_to be_equivalent(SliceMove.new(Face::D, CubeDirection::BACKWARD, 1), 4)
    expect(SliceMove.new(Face::U, CubeDirection::FORWARD, 1)).not_to be_equivalent(SliceMove.new(Face::D, CubeDirection::FORWARD, 2), 4)
    expect(SliceMove.new(Face::U, CubeDirection::FORWARD, 1)).not_to be_equivalent(SliceMove.new(Face::U, CubeDirection::BACKWARD, 2), 4)
  end

  it 'recognizes equivalent normal moves' do
    expect(FatMove.new(Face::U, CubeDirection::FORWARD, 1)).to be_equivalent(FatMove.new(Face::U, CubeDirection::FORWARD, 1), 3)
    expect(FatMove.new(Face::U, CubeDirection::FORWARD, 1)).not_to be_equivalent(FatMove.new(Face::U, CubeDirection::FORWARD, 2), 3)
    expect(FatMove.new(Face::U, CubeDirection::FORWARD, 1)).not_to be_equivalent(FatMove.new(Face::U, CubeDirection::BACKWARD, 1), 3)
    expect(FatMove.new(Face::U, CubeDirection::FORWARD, 1)).not_to be_equivalent(FatMove.new(Face::D, CubeDirection::FORWARD, 1), 3)
    expect(FatMove.new(Face::U, CubeDirection::FORWARD, 1)).not_to be_equivalent(FatMove.new(Face::D, CubeDirection::BACKWARD, 1), 3)
  end

  it 'returns the right string representation for inner m slice moves' do
    expect(InnerMSliceMove.new(Face::U, CubeDirection::FORWARD, 1).to_s).to eq("E'")
    expect(InnerMSliceMove.new(Face::F, CubeDirection::FORWARD, 1).to_s).to eq('S')
    expect(InnerMSliceMove.new(Face::R, CubeDirection::FORWARD, 1).to_s).to eq("M'")
    expect(InnerMSliceMove.new(Face::L, CubeDirection::FORWARD, 1).to_s).to eq('M')
    expect(InnerMSliceMove.new(Face::B, CubeDirection::FORWARD, 1).to_s).to eq("S'")
    expect(InnerMSliceMove.new(Face::D, CubeDirection::FORWARD, 1).to_s).to eq('E')
  end

  it 'returns the right string representation for fat m slice moves' do
    expect(FatMSliceMove.new(Face::U, CubeDirection::FORWARD).to_s).to eq("E'")
    expect(FatMSliceMove.new(Face::F, CubeDirection::FORWARD).to_s).to eq('S')
    expect(FatMSliceMove.new(Face::R, CubeDirection::FORWARD).to_s).to eq("M'")
    expect(FatMSliceMove.new(Face::L, CubeDirection::FORWARD).to_s).to eq('M')
    expect(FatMSliceMove.new(Face::B, CubeDirection::FORWARD).to_s).to eq("S'")
    expect(FatMSliceMove.new(Face::D, CubeDirection::FORWARD).to_s).to eq('E')
  end

  it 'returns the right string representation for maybe fat maybe inner m slice moves' do
    expect(MaybeFatMSliceMaybeInnerMSliceMove.new(Face::U, CubeDirection::FORWARD).to_s).to eq("E'")
    expect(MaybeFatMSliceMaybeInnerMSliceMove.new(Face::F, CubeDirection::FORWARD).to_s).to eq('S')
    expect(MaybeFatMSliceMaybeInnerMSliceMove.new(Face::R, CubeDirection::FORWARD).to_s).to eq("M'")
    expect(MaybeFatMSliceMaybeInnerMSliceMove.new(Face::L, CubeDirection::FORWARD).to_s).to eq('M')
    expect(MaybeFatMSliceMaybeInnerMSliceMove.new(Face::B, CubeDirection::FORWARD).to_s).to eq("S'")
    expect(MaybeFatMSliceMaybeInnerMSliceMove.new(Face::D, CubeDirection::FORWARD).to_s).to eq('E')
  end

  it 'returns the right string representation for slice moves' do
    expect(SliceMove.new(Face::U, CubeDirection::FORWARD, 1).to_s).to eq('u')
    expect(SliceMove.new(Face::F, CubeDirection::FORWARD, 1).to_s).to eq('f')
    expect(SliceMove.new(Face::R, CubeDirection::FORWARD, 1).to_s).to eq('r')
    expect(SliceMove.new(Face::L, CubeDirection::FORWARD, 1).to_s).to eq('l')
    expect(SliceMove.new(Face::B, CubeDirection::FORWARD, 1).to_s).to eq('b')
    expect(SliceMove.new(Face::D, CubeDirection::FORWARD, 1).to_s).to eq('d')
  end

  it 'returns the right string representation for fat moves' do
    expect(FatMove.new(Face::U, CubeDirection::FORWARD, 1).to_s).to eq('U')
    expect(FatMove.new(Face::F, CubeDirection::FORWARD, 1).to_s).to eq('F')
    expect(FatMove.new(Face::R, CubeDirection::FORWARD, 1).to_s).to eq('R')
    expect(FatMove.new(Face::L, CubeDirection::FORWARD, 1).to_s).to eq('L')
    expect(FatMove.new(Face::B, CubeDirection::FORWARD, 1).to_s).to eq('B')
    expect(FatMove.new(Face::D, CubeDirection::FORWARD, 1).to_s).to eq('D')

    expect(FatMove.new(Face::U, CubeDirection::FORWARD, 2).to_s).to eq('Uw')
    expect(FatMove.new(Face::F, CubeDirection::FORWARD, 2).to_s).to eq('Fw')
    expect(FatMove.new(Face::R, CubeDirection::FORWARD, 2).to_s).to eq('Rw')
    expect(FatMove.new(Face::L, CubeDirection::FORWARD, 2).to_s).to eq('Lw')
    expect(FatMove.new(Face::B, CubeDirection::FORWARD, 2).to_s).to eq('Bw')
    expect(FatMove.new(Face::D, CubeDirection::FORWARD, 2).to_s).to eq('Dw')

    expect(FatMove.new(Face::U, CubeDirection::FORWARD, 3).to_s).to eq('3Uw')
    expect(FatMove.new(Face::F, CubeDirection::FORWARD, 3).to_s).to eq('3Fw')
    expect(FatMove.new(Face::R, CubeDirection::FORWARD, 3).to_s).to eq('3Rw')
    expect(FatMove.new(Face::L, CubeDirection::FORWARD, 3).to_s).to eq('3Lw')
    expect(FatMove.new(Face::B, CubeDirection::FORWARD, 3).to_s).to eq('3Bw')
    expect(FatMove.new(Face::D, CubeDirection::FORWARD, 3).to_s).to eq('3Dw')
  end

  it 'returns the right string representation for maybe fat maybe slice moves' do
    expect(MaybeFatMaybeSliceMove.new(Face::U, CubeDirection::FORWARD).to_s).to eq('u')
    expect(MaybeFatMaybeSliceMove.new(Face::F, CubeDirection::FORWARD).to_s).to eq('f')
    expect(MaybeFatMaybeSliceMove.new(Face::R, CubeDirection::FORWARD).to_s).to eq('r')
    expect(MaybeFatMaybeSliceMove.new(Face::L, CubeDirection::FORWARD).to_s).to eq('l')
    expect(MaybeFatMaybeSliceMove.new(Face::B, CubeDirection::FORWARD).to_s).to eq('b')
    expect(MaybeFatMaybeSliceMove.new(Face::D, CubeDirection::FORWARD).to_s).to eq('d')
  end

  it 'raises if asked to translate a direction to a face that is neither its axis face nor its axis face opposite' do
    move = FatMove.new(Face::U, CubeDirection::FORWARD, 1)
    expect { move.translated_direction(Face::F) }.to raise_error(ArgumentError)
  end

  it 'raises if asked to translate a slice index to a face that is neither its axis face nor its axis face opposite' do
    move = SliceMove.new(Face::U, CubeDirection::FORWARD, 1)
    expect { move.translated_slice_index(Face::F) }.to raise_error(ArgumentError)
  end

  it 'raises if asked to decide the meaning of a move like u that can be a slice move on big cubes or a fat move on 3x3 on 2x2' do
    move = MaybeFatMaybeSliceMove.new(Face::U, CubeDirection::FORWARD)
    expect { move.decide_meaning(2) }.to raise_error(ArgumentError)
  end

  it 'rotates an U move around U to U' do
    move = FatMove.new(Face::U, CubeDirection::FORWARD, 1)
    rotation = Rotation.new(Face::U, CubeDirection::FORWARD)
    expect(move.rotate_by(rotation)).to eq(move)
  end

  it 'rotates an F move around U to R' do
    move = FatMove.new(Face::F, CubeDirection::FORWARD, 1)
    rotation = Rotation.new(Face::U, CubeDirection::ZERO)
    expect(move.rotate_by(rotation)).to eq(move)
  end

  it 'rotates an F move around U to L' do
    move = FatMove.new(Face::F, CubeDirection::FORWARD, 1)
    rotation = Rotation.new(Face::U, CubeDirection::FORWARD)
    rotated_move = FatMove.new(Face::L, CubeDirection::FORWARD, 1)
    expect(move.rotate_by(rotation)).to eq(rotated_move)
  end

  it 'rotates an F move around U to R' do
    move = FatMove.new(Face::F, CubeDirection::FORWARD, 1)
    rotation = Rotation.new(Face::U, CubeDirection::BACKWARD)
    rotated_move = FatMove.new(Face::R, CubeDirection::FORWARD, 1)
    expect(move.rotate_by(rotation)).to eq(rotated_move)
  end

  it 'rotates an F move around U to B' do
    move = FatMove.new(Face::F, CubeDirection::FORWARD, 1)
    rotation = Rotation.new(Face::U, CubeDirection::DOUBLE)
    rotated_move = FatMove.new(Face::B, CubeDirection::FORWARD, 1)
    expect(move.rotate_by(rotation)).to eq(rotated_move)
  end

  it "mirrors an U move around F to U'" do
    move = FatMove.new(Face::U, CubeDirection::FORWARD, 1)
    mirrored_move = FatMove.new(Face::U, CubeDirection::BACKWARD, 1)
    expect(move.mirror(Face::F)).to eq(mirrored_move)
  end

  it 'mirrors an U2 move around F to U2' do
    move = FatMove.new(Face::U, CubeDirection::DOUBLE, 1)
    expect(move.mirror(Face::F)).to eq(move)
  end

  it 'mirrors an U2 move around U to D2' do
    move = FatMove.new(Face::U, CubeDirection::DOUBLE, 1)
    mirrored_move = FatMove.new(Face::D, CubeDirection::DOUBLE, 1)
    expect(move.mirror(Face::U)).to eq(mirrored_move)
  end

  it "mirrors an U move around U to D'" do
    move = FatMove.new(Face::U, CubeDirection::FORWARD, 1)
    mirrored_move = FatMove.new(Face::D, CubeDirection::BACKWARD, 1)
    expect(move.mirror(Face::U)).to eq(mirrored_move)
  end

  it "mirrors an U move around D to D'" do
    move = FatMove.new(Face::U, CubeDirection::FORWARD, 1)
    mirrored_move = FatMove.new(Face::D, CubeDirection::BACKWARD, 1)
    expect(move.mirror(Face::D)).to eq(mirrored_move)
  end
end
