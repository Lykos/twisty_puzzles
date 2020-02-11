require 'cube_trainer/native'
require 'cube_trainer/buffer_helper'
require 'cube_trainer/results_persistence'
require 'cube_trainer/probabilities'
require 'cube_trainer/math_helper'

module CubeTrainer

  class StatsComputer

    include MathHelper

    def initialize(now, options, results_persistence=ResultsPersistence.create_for_production)
      raise TypeError unless now.is_a?(Time)
      raise TypeError unless results_persistence.respond_to?(:load_results)
      @now = now
      @options = options
      @results_persistence = results_persistence
      mode = BufferHelper.mode_for_options(options)
      results = @results_persistence.load_results(mode)
      @grouped_results = results.group_by { |c| c.input_representation }
      grouped_averages = @grouped_results.collect { |c, rs| [c, average_time(rs)] }
      @averages = grouped_averages.sort_by { |t| -t[1] }

      old_grouped_results = results.select { |r| r.timestamp < now - 24 * 3600 }.group_by { |c| c.input_representation }
      old_grouped_averages = old_grouped_results.collect { |c, rs| [c, average_time(rs)] }
      @old_averages = old_grouped_averages.sort_by { |t| -t[1] }

      @num_results = results.length
      @num_recent_results = results.count { |r| r.timestamp > now - 24 * 3600 }
    end

    attr_reader :averages, :old_averages, :num_results, :num_recent_results

    def input_stats(inputs)
      hashes = inputs.collect { |e| e.representation.hash }
      filtered_results = @grouped_results.select { |input, rs| hashes.include?(input.hash) }
      newish_elements = filtered_results.collect { |input, rs| rs.length }.count { |l| 1 <= l && l < @options.new_item_boundary }
      found = filtered_results.keys.uniq.length
      total = inputs.length
      missing = total - found
      {
        found: found,
        total: total,
        newish_elements: newish_elements,
        missing: missing
      }
    end

    def expected_time_per_type_stats
      @expected_time_per_type_stats ||= ExpectedTimeComputer.new(@now, @options, @results_persistence).compute_expected_time_per_type_stats
    end

    # Interesting time boundaries to see the number of bad results above that boundary. It allows to display things like "9 results are above 4.5 and one result is above 5"
    def cutoffs
      return [] if @averages.length < 20
      # TODO: Take mode and target into account
      some_bad_result = @averages[9][1]
      step = floor_to_nice(some_bad_result / 10)
      start = floor_to_step(some_bad_result, step)
      finish = start + step * 5
      start.step(finish, step).to_a
    end

    def bad_results
      @bad_results ||= begin
                       cutoffs.collect do |cutoff|
                         [cutoff, @averages.count { |v| v[1] > cutoff }]
                       end
                     end
    end

    def compute_total_average(averages)
      if averages.empty? then Float::INFINITY else averages.collect { |c, t| t }.reduce(:+) / averages.length end
    end

    def total_average
      @total_average ||= compute_total_average(@averages)
    end
      
    def old_total_average
      @old_total_average ||= compute_total_average(@old_averages)
    end
      
    def average_time(results)
      avg = Native::CubeAverage.new(5, 0)
      results.sort_by { |r| r.timestamp }.each { |r| avg.push(r.time_s) }
      avg.average
    end
  
    def float_times_s(results)
    end
    
  end

end
