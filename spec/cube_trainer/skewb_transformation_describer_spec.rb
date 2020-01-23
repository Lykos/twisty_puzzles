require 'cube_trainer/parser'
require 'cube_trainer/skewb_transformation_describer'

include CubeTrainer

CYCLE_REGEXP = Regexp.new("#{SkewbTransformationDescriber::DOUBLE_ARROW}|#{SkewbTransformationDescriber::ARROW}| <-> | -> ")
                                                                        
def canonicalize_transformation_descriptions(transformation_descriptions)
  transformation_descriptions.map do |s|
    parts = s.to_s.split(CYCLE_REGEXP)
    if parts.length == 1
      parts
    else
      parts = parts[0..-2] if parts[0] == parts[-1]
      parts.rotate(parts.index(parts.min))
    end
  end.sort
end

RSpec::Matchers.define :be_the_same_descriptions_as do |expected|
  match do |actual|
    canonicalize_transformation_descriptions(expected) == canonicalize_transformation_descriptions(actual)
  end
end

describe SkewbTransformationDescriber do
  let(:top_corners) { Corner::ELEMENTS.select { |c| c.face_symbols.first == :U } }
  let(:bottom_corners) { Corner::ELEMENTS.select { |c| c.face_symbols.first == :D } }
  let(:non_bottom_faces) { Face::ELEMENTS.select { |c| c.face_symbol != :D } }
  let(:color_scheme) { ColorScheme::BERNHARD }
  let(:top_corners_describer) { SkewbTransformationDescriber.new([], top_corners, :show_staying, color_scheme) }
  let(:centers_describer) { SkewbTransformationDescriber.new(non_bottom_faces, [], :omit_staying, color_scheme) }
  let(:bottom_describer) { SkewbTransformationDescriber.new([], bottom_corners, :omit_staying, color_scheme) }

  it 'should describe center transformations of sledges accurately' do
    alg = parse_sarahs_skewb_algorithm("F' L F L'")
    expect(centers_describer.transformation_descriptions(alg)).to be_the_same_descriptions_as ["F <-> U", "R <-> L"]
  end

  it 'should describe center transformations of F moves accurately' do
    alg = parse_sarahs_skewb_algorithm("F")
    expect(centers_describer.transformation_descriptions(alg)).to be_the_same_descriptions_as ["U -> R -> F -> U"]
  end

  it 'should describe corner transformations of sledges accurately' do
    alg = parse_sarahs_skewb_algorithm("F' L F L'")
    expect(top_corners_describer.source_descriptions(alg)).to be_the_same_descriptions_as ["FLU -> UFL", "RFU -> URF", "BUL -> ULB", "RUB -> UBR"]
  end

  it 'should describe corner transformations of F moves accurately' do
    alg = parse_sarahs_skewb_algorithm("F")
    expect(top_corners_describer.source_descriptions(alg)).to be_the_same_descriptions_as ["FUR -> URF", "FLU -> UBR", "FRD -> UFL", "ULB stays"]
  end

  it 'should describe sources of layer corners after sledges accurately' do
    alg = parse_sarahs_skewb_algorithm("F' L F L'")
    expect(bottom_describer.source_descriptions(alg)).to be_the_same_descriptions_as []
  end

  it 'should describe sources of layer corners after F moves accurately' do
    alg = parse_sarahs_skewb_algorithm("F")
    expect(bottom_describer.source_descriptions(alg)).to be_the_same_descriptions_as ["BRU -> DFR"]
  end
end