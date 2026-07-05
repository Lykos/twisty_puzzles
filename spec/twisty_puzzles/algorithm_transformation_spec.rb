# frozen_string_literal: true

describe AlgorithmTransformation do
  let(:rotation) { Rotation.new(Face::U, CubeDirection::FORWARD) }
  let(:zero_rotation) { Rotation.new(Face::U, CubeDirection::ZERO) }
  let(:transformation) { described_class.new(rotation, true, Face::F) }
  let(:identity_transformation) { described_class.new(zero_rotation, false, Face::F) }

  it 'returns properties correctly' do
    expect(transformation.rotation).to eq(rotation)
    expect(transformation.mirror).to be(true)
    expect(transformation.mirror_normal_face).to eq(Face::F)
  end

  it 'checks identity correctly' do
    expect(transformation.identity?).to be(false)
    expect(identity_transformation.identity?).to be(true)
  end

  it 'transforms algorithms correctly' do
    alg = parse_algorithm('R U')
    mirrored_alg = alg.mirror(Face::F)
    expected = mirrored_alg.rotate_by(rotation)
    expect(transformation.transformed(alg)).to eq(expected)
  end

  it 'creates transformations around a face' do
    transformations = described_class.around_face(Face::U)
    expect(transformations.length).to eq(8)
    expect(transformations.count(&:identity?)).to eq(1)
  end

  it 'creates transformations around a face without identity' do
    transformations = described_class.around_face_without_identity(Face::U)
    expect(transformations.length).to eq(7)
    expect(transformations.any?(&:identity?)).to be(false)
  end
end
