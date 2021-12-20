# frozen_string_literal: true

require 'twisty_puzzles/utils/array_helper'
require 'twisty_puzzles/utils/string_helper'
require 'twisty_puzzles/sticker_cycle_factory'
require 'twisty_puzzles/cube'

module TwistyPuzzles
  # A cycle of parts of the cube, e.g. a corner 3 cycle.
  # Note that this is abstract and contains no information on the cube size.
  # E.g. for wings on a 7x7, it's not clear whether inner or outer wings are used.
  # Check StickerCycleFactory for making it concrete and applyable.
  class PartCycle
    include Utils::ArrayHelper
    include Utils::StringHelper
    extend Utils::StringHelper

    RAW_DATA_RESERVED = [' ', '(', ')'].freeze

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

    def contains_any_part?(parts)
      !(@parts & parts).empty?
    end

    def to_s
      @parts.join(' ')
    end

    def to_raw_data
      "#{simple_class_name(part_type)}(#{self})"
    end

    def length
      @parts.length
    end

    def rotate_by(number)
      self.class.new(@parts.rotate(number))
    end

    def map_rotate_by(number)
      self.class.new(@parts.map { |p| p.rotate_by(number) })
    end

    def <=>(other)
      @parts <=> other.parts
    end

    def canonicalize
      @canonicalize ||=
        @parts.map.with_index do |part, index|
          min_part = part.rotations.min
          map_rotate_by_number = part.rotations.index(min_part)
          rotate_by(index).map_rotate_by(map_rotate_by_number)
        end.min
    end

    # Note that this returns the same answer for all rotations of one part.
    def contains?(part)
      @parts.any? { |p| p.turned_equals?(part) }
    end

    # Returns an equivalent cycle that starts with the given part.
    # Raises an error if the cycle doesn't contain the given part.
    def start_with(part)
      raise ArgumentError unless contains?(part)

      index = @parts.find_index { |p| p.turned_equals?(part) }
      map_rotate_by_number = @parts[index].rotations.index(part)
      rotate_by(@parts.length - index).map_rotate_by(map_rotate_by_number)
    end

    def equivalent?(other)
      self == other || canonicalize == other.canonicalize
    end

    def inverse
      self.class.new([@parts[0]] + @parts[1..].reverse)
    end

    def self.from_raw_data(data)
      raw_part_type, raw_parts = data.match(/(.*)\((.*)\)/).captures
      part_type = PART_TYPES.find { |p| simple_class_name(p) == raw_part_type }
      parts = raw_parts.split.map { |r| part_type.parse(r) }
      new(parts)
    end

    def check_type_consistency(parts)
      return unless parts.any? { |p| p.class != parts.first.class }

      raise TypeError, "Cycles of heterogenous piece types #{parts.inspect} are not supported."
    end
  end
end
