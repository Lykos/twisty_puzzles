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
      raise ArgumentError if parts.empty?

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

    def part_type
      @parts.first.class
    end

    def to_s
      @parts.join(' ')
    end

    def to_raw_data
      "#{part_type}(#{self})"
    end

    def length
      @parts.length
    end

    def self.from_raw_data(data)
      raw_part_type, raw_parts = data.match(/(.*)\((.*)\)/).captures
      part_type = PART_TYPES.find { |p| p.name == raw_part_type }
      parts = raw_parts.split.map { |r| part_type.parse(r) }
      new(parts)
    end

    def check_type_consistency(parts)
      return unless parts.any? { |p| p.class != parts.first.class }

      raise TypeError, "Cycles of heterogenous piece types #{parts.inspect} are not supported."
    end
  end
end
