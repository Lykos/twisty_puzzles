# frozen_string_literal: true

require 'cube_trainer/alg_name'
require 'cube_trainer/training/alg_hint_parser'
require 'cube_trainer/training/input_sampler'
require 'cube_trainer/training/restricted_hinter'
require 'cube_trainer/training/disjoint_union_hinter'
require 'cube_trainer/training/input_item'
require 'cube_trainer/training/sequence_hinter'

module CubeTrainer
  module Training
    # Base class for alg sets (e.g. PLLs).
    class AlgSet
      include Utils::StringHelper

      def initialize(options)
        @options = options
      end

      def input_sampler(results_model)
        InputSampler.new(
          input_items,
          results_model,
          goal_badness,
          @options.verbose,
          @options.new_item_boundary
        )
      end

      def goal_badness
        raise NotImplementedError
      end

      def name
        snake_case_class_name(self.class)
      end

      def hinter(*)
        @hinter ||= AlgHintParser.parse_hints(name, @options.verbose)
      end

      def input_items
        @input_items ||= generate_input_items
      end

      def generate_input_items
        state = @options.color_scheme.solved_cube_state(@options.cube_size)
        hinter.entries.map do |name, alg|
          alg.inverse.apply_temporarily_to(state) do |s|
            InputItem.new(name, s.dup)
          end
        end
      end

      def generate_alg_names
        raise NotImplementedError
      end
    end

    # PLLs alg set.
    class Plls < AlgSet
      def goal_badness
        1.0
      end
    end

    # Alg set for solving OLL first and then CP with a PLL.
    class OllsPlusCp < AlgSet
      def goal_badness
        1.0
      end
    end

    # COLLs alg set.
    class Colls < AlgSet
      def goal_badness
        1.0
      end
    end
  end
end