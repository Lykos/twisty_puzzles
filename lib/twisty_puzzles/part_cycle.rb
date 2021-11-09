# frozen_string_literal: true

require 'twisty_puzzles/utils/array_helper'
require 'twisty_puzzles/sticker_cycle_factory'
require 'twisty_puzzles/cube'

module TwistyPuzzles
  # A cycle of parts of the cube, e.g. a corner 3 cycle.
  # Note that this is abstract and contains no information on the cube size.
  # E.g. for wings on a 7x7, it's not clear whether inner or outer wings are used.
  # Check StickerCycleFactory for making it concrete and applyable.
  class PartCycle
    include Utils::ArrayHelper

    def initialize(parts)
      check_types(parts, Part)
      check_type_consistency(parts)

      @parts = parts
    end

    attr_reader :parts

    def eql?(other)
      self.class.equal?(other.class) && @parts == other.parts
    end

    alias == eql?

    def hash
      @hash ||= ([self.class] + @parts).hash
    end

    def check_type_consistency(parts)
      return unless parts.any? { |p| p.class != parts.first.class }

      raise TypeError, "Cycles of heterogenous piece types #{parts.inspect} are not supported."
    end
  end
end
