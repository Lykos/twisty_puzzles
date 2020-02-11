require 'cube_trainer/color_scheme'
require 'cube_trainer/core/cube'
require 'cube_trainer/core/parser'
require 'cube_trainer/skewb_layer_classifier'

include CubeTrainer

describe SkewbLayerClassifier do
  
  let (:color_scheme) { ColorScheme::BERNHARD }
  let (:classifier) { SkewbLayerClassifier.new(Face::D, color_scheme) }

  it 'should classify the solved layer correctly' do
    expect(classifier.classify_layer(Algorithm.empty)).to be == "4_solved"
    expect(classifier.classify_layer(parse_sarahs_skewb_algorithm("R' F R F'"))).to be == "4_solved"
  end

  it 'should classify a one move layer correctly' do
    expect(classifier.classify_layer(parse_sarahs_skewb_algorithm("R"))).to be == "3_solved"
  end
  
  it 'should classify a two opposite solved layer correctly' do
    expect(classifier.classify_layer(parse_sarahs_skewb_algorithm("R L"))).to be == "2_opposite_solved"
  end
  
  it 'should classify a two adjacent solved layer correctly' do
    expect(classifier.classify_layer(parse_sarahs_skewb_algorithm("F L"))).to be == "2_adjacent_solved"
  end
  
  it 'should classify a layer with one solved piece correctly' do
    expect(classifier.classify_layer(parse_sarahs_skewb_algorithm("F L R"))).to be == "1_solved"
  end
  
  it 'should classify a layer with no solved piece correctly' do
    expect(classifier.classify_layer(parse_sarahs_skewb_algorithm("F L R B"))).to be == "0_solved"
  end
  
end
