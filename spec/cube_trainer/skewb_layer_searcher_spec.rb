require 'cube_trainer/skewb_layer_searcher'
require 'cube_trainer/color_scheme'

include CubeTrainer

describe SkewbLayerSearcher do

  let(:verbose) { false }
  let(:color_scheme) { ColorScheme::BERNHARD }

  it 'should find all 0 move layers' do
    expect(SkewbLayerSearcher::calculate(color_scheme, verbose, 0)).to be == [[Algorithm.empty]]
  end

  it 'should find all 0-1 move layers' do
    algs = SkewbLayerSearcher::calculate(color_scheme, verbose, 1)
    expect(algs.length).to be == 2
    expect(algs[0]).to be == [Algorithm.empty]
    expect(algs[1].length).to be == 1
    one_move_alg = algs[1][0]
    expect(one_move_alg.length).to be == 1
    expect(one_move_alg.moves.first).to be_a(SkewbMove)
  end

end