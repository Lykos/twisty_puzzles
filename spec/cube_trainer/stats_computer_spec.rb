require 'cube_trainer/stats_computer'
require 'cube_trainer/result'
require 'cube_trainer/commutator_options'
require 'cube_trainer/input_item'
require 'ostruct'

describe StatsComputer do

  let(:now) { Time.at(0) }
  let(:t_10_minutes_ago) { now - 600 }
  let(:t_2_hours_ago) { now - 2 * 3600 }
  let(:t_2_days_ago) { now - 2 * 24 * 3600 }
  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:options) {
    options = OpenStruct.new
    options.cube_size = 3
    options.letter_scheme = letter_scheme
    options.commutator_info = CommutatorOptions::COMMUTATOR_TYPES['corners']
    options.new_item_boundary = 5
    options
  }
  let(:letter_pair_a) { LetterPair.new(['a', 'a']) }
  let(:letter_pair_b) { LetterPair.new(['a', 'b']) }
  let(:letter_pair_c) { LetterPair.new(['a', 'c']) }
  let(:fill_letter_pairs) { ('a'..'z').map { |l| LetterPair.new(['b', l]) } }
  let(:mode) { BufferHelper.mode_for_options(options) }
  let(:results) {
    other_mode_results = CommutatorOptions::COMMUTATOR_TYPES.select { |k, v| k != 'corners' }.map do |k, v|
      patched_options = options.dup
      patched_options.commutator_info = v
      mode = BufferHelper.mode_for_options(patched_options)
      Result.new(mode, t_2_days_ago, 1.0, letter_pair_b, 0, nil)
    end
    fill_results = fill_letter_pairs.map { |ls| Result.new(mode, t_2_days_ago, 1.0, ls, 0, nil) }
    [
      Result.new(mode, t_10_minutes_ago, 1.0, letter_pair_a, 0, nil),
      Result.new(mode, t_10_minutes_ago, 2.0, letter_pair_a, 0, nil),
      Result.new(mode, t_10_minutes_ago, 3.0, letter_pair_a, 0, nil),
      Result.new(mode, t_10_minutes_ago, 4.0, letter_pair_a, 0, nil),
      Result.new(mode, t_10_minutes_ago, 5.0, letter_pair_a, 0, nil),
      Result.new(mode, t_10_minutes_ago - 1, 6.0, letter_pair_a, 0, nil),
      Result.new(mode, t_2_hours_ago, 7.0, letter_pair_a, 0, nil),
      Result.new(mode, t_2_days_ago, 10.0, letter_pair_a, 0, nil),
      Result.new(mode, t_2_days_ago, 11.0, letter_pair_a, 0, nil),
      Result.new(mode, t_2_days_ago, 12.0, letter_pair_a, 0, nil),
      Result.new(mode, t_2_days_ago, 13.0, letter_pair_a, 0, nil),
      Result.new(mode, t_2_days_ago, 14.0, letter_pair_a, 0, nil),
      Result.new(mode, t_2_hours_ago, 10.0, letter_pair_b, 0, nil),
    ] + fill_results + other_mode_results
  }
  let(:results_persistence) {
    persistence = ResultsPersistence.create_in_memory
    results.each { |r| persistence.record_result(r) }
    persistence
  }
  let(:computer) { StatsComputer.new(now, options, results_persistence) }

  it 'should compute detailed averages for all our results' do
    expect(computer.averages).to be == [[letter_pair_b, 10.0], [letter_pair_a, 3.0]] + fill_letter_pairs.map { |ls| [ls, 1.0] }
  end

  it 'should compute which are our bad results' do
    expect(computer.bad_results).to be == [[1.0, 2], [1.1, 2], [1.2, 2], [1.3, 2], [1.4, 2], [1.5, 2]]
  end

  it 'should compute how many results we had now and 24 hours ago' do
    expect(computer.total_average).to be == (26 * 1.0 + 10.0 + 3.0) / 28
    expect(computer.old_total_average).to be == (26 * 1.0 + 12.0) / 27
  end

  it 'should compute how long each part of the solve takes' do
    stats = computer.expected_time_per_type_stats
    expect(stats.map { |s| s[:name] }.sort).to be == ['corner_3twists', 'corners', 'edges', 'floating_2flips', 'floating_2twists']
    expect(stats.map { |s| s[:weight] }.reduce(:+)).to be == 1.0
    stats.each do |s|
      expect(s[:expected_algs]).to be_a(Float)
      expect(s[:total_time]).to be_a(Float)
      expect(s[:weight]).to be_a(Float)
      if s[:name] == 'corners'
        expect(s[:average]).to be == (26 * 1.0 + 10.0 + 3.0) / 28
      else
        expect(s[:average]).to be == 1.0
      end
    end
  end

  it 'should compute how many items we have already seen and how many are new' do
    inputs = [letter_pair_a, letter_pair_b, letter_pair_c].map { |ls| InputItem.new(ls) }
    stats = computer.input_stats(inputs)
    expect(stats[:found]).to be == 2
    expect(stats[:total]).to be == 3
    expect(stats[:newish_elements]).to be == 1
    expect(stats[:missing]).to be == 1
    expect(computer.num_results).to be == 13 + 26
    expect(computer.num_recent_results).to be == 8
  end
  
end