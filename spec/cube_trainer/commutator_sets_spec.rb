require 'cube_trainer/commutator_sets'
require 'ostruct'
require 'cube_trainer/commutator_options'
require 'cube_trainer/stub_results_model'

RSpec.shared_examples 'commutator_set' do |info|
  let (:letter_scheme) { BernhardLetterScheme.new }
  let (:options) {
    options = CommutatorOptions.default_options
    options.commutator_info = info
    options.cube_size = info.default_cube_size
    options.test_comms_mode = :fail
    options
  }
  let (:results_model) { StubResultsModel.new }
  
  it 'should parse all comms correctly and give a hint on the first one' do
    generator = info.generator_class.new(results_model, options)
    input_item = generator.input_items.sample
    generator.hinter.hints(input_item.representation)
  end
end

CommutatorOptions::COMMUTATOR_TYPES.each do |key, info|
  next unless info.default_cube_size
  
  describe info.generator_class do
    it_behaves_like 'commutator_set', info
  end
end

