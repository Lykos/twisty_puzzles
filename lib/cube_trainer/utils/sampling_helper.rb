# frozen_string_literal: true

module CubeTrainer
  module Utils
    module SamplingHelper
      # Draw a random sample from `array` and use `block` to calculate the weight of each item.
      def sample_by(array, &block)
        raise ArgumentError, 'Cannot sample empty array.' if array.empty?

        weights = array.collect(&block)
        unless weights.all? { |w| w.is_a?(Numeric) }
          raise TypeError, 'Negative weights are not allowed for sampling.'
      end
        if weights.any? { |w| w < 0.0 }
          raise ArgumentError, 'Negative weights are not allowed for sampling.'
      end

        weight_sum = weights.reduce(:+)
        if weight_sum == 0.0
          raise ArgumentError, "Can't sample for total weight 0.0."
      end

        number = rand * weight_sum
        prefix_weight = 0.0
        index = 0
        while prefix_weight < number
          prefix_weight += weights[index]
          index += 1
        end
        array[index - 1]
      end
    end
  end
end
