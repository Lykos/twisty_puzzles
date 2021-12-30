# frozen_string_literal: true

require 'set'
require 'twisty_puzzles/coordinate'
require 'twisty_puzzles/cube_state'
require 'twisty_puzzles/reversible_applyable'

module TwistyPuzzles
  # A sticker cycle that can be applied to a cube state.
  # TODO: Deprecate
  class StickerCycle
    include ReversibleApplyable

    def self.from_coordinates(cube_size, coordinates)
      CubeState.check_cube_size(cube_size)
      raise TypeError unless coordinates.all?(Coordinate)

      new(Native::StickerCycle.new(cube_size, coordinates.map(&:native)))
    end

    def initialize(native)
      raise TypeError unless native.is_a?(Native::StickerCycle)

      @native = native
    end

    attr_reader :native

    def eql?(other)
      self.class.equal?(other.class) && @native == other.native
    end

    alias == eql?

    def hash
      @hash ||= [self.class, @native].hash
    end

    def cube_size
      @native.cube_size
    end

    def length
      @native.length
    end

    def apply_to(cube_state)
      raise TypeError unless cube_state.is_a?(CubeState)

      @native.apply_to(cube_state.native)
    end

    def inverse
      StickerCycle.new(@native.inverse)
    end
  end

  # A set of disjoint sticker cycles that can be applied to a cube state together
  # TODO: Deprecate
  class StickerCycles
    include ReversibleApplyable

    def initialize(cube_size, sticker_cycles)
      affected_set = Set[]
      sticker_cycles.each do |c|
        raise TypeError unless c.is_a?(StickerCycle)

        c.native.coordinates.each do |s|
          unless affected_set.add?(s)
            raise ArgumentError,
                  'There is an intersection between part cycles'
          end
        end
      end
      @cube_size = cube_size
      @sticker_cycles = sticker_cycles
    end

    attr_reader :cube_size, :sticker_cycles

    def apply_to(cube_state)
      raise TypeError unless cube_state.is_a?(CubeState)
      raise ArgumentError unless cube_state.n == @cube_size

      @sticker_cycles.each { |c| c.apply_to(cube_state) }
    end

    def +(other)
      raise TypeError unless other.is_a?(StickerCycles)
      raise ArgumentError unless @cube_size == other.cube_size

      StickerCycles.new(@cube_size, @sticker_cycles + other.sticker_cycles)
    end

    def inverse
      StickerCycles.new(@cube_size, @sticker_cycles.map(&:inverse))
    end
  end
end
