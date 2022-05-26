# frozen_string_literal: true

describe Parser do
  it 'parses a simple commutator' do
    expect(parse_commutator('[R, U]')).to eq(
                                            PureCommutator.new(
                                              Algorithm.move(FatMove.new(Face::R, CubeDirection::FORWARD)),
                                              Algorithm.move(FatMove.new(Face::U, CubeDirection::FORWARD))
                                            )
                                          )
  end

  it 'parses a simple commutator without brackets' do
    expect(parse_commutator('R, U')).to eq(
                                          PureCommutator.new(
                                            Algorithm.move(FatMove.new(Face::R, CubeDirection::FORWARD)),
                                            Algorithm.move(FatMove.new(Face::U, CubeDirection::FORWARD))
                                          )
                                        )
  end

  it 'parses two commutators with a plus' do
    expect(parse_commutator('[R, U] + [L, U]')).to eq(
                                                     CommutatorSequence.new(
                                                       [
                                                         PureCommutator.new(
                                                           Algorithm.move(FatMove.new(Face::R, CubeDirection::FORWARD)),
                                                           Algorithm.move(FatMove.new(Face::U, CubeDirection::FORWARD))
                                                         ),
                                                         PureCommutator.new(
                                                           Algorithm.move(FatMove.new(Face::L, CubeDirection::FORWARD)),
                                                           Algorithm.move(FatMove.new(Face::U, CubeDirection::FORWARD))
                                                         ),
                                                       ]
                                                     )
                                                   )
  end

  it 'parses two commutators without brackets with a plus' do
    expect(parse_commutator('R, U + L, U')).to eq(
                                                 CommutatorSequence.new(
                                                   [
                                                     PureCommutator.new(
                                                       Algorithm.move(FatMove.new(Face::R, CubeDirection::FORWARD)),
                                                       Algorithm.move(FatMove.new(Face::U, CubeDirection::FORWARD))
                                                     ),
                                                     PureCommutator.new(
                                                       Algorithm.move(FatMove.new(Face::L, CubeDirection::FORWARD)),
                                                       Algorithm.move(FatMove.new(Face::U, CubeDirection::FORWARD))
                                                     ),
                                                   ]
                                                 )
                                               )
  end
end
