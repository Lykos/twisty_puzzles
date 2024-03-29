# frozen_string_literal: true

require 'twisty_puzzles/cube'
require 'twisty_puzzles/cube_constants'
require 'twisty_puzzles/coordinate'
require 'twisty_puzzles/cube_print_helper'
require 'twisty_puzzles/utils/array_helper'
require 'twisty_puzzles/native'

module TwistyPuzzles
  # Represents the state (i.e. the sticker positions) of a cube.
  class CubeState
    include Utils::ArrayHelper
    include CubePrintHelper
    include CubeConstants

    def self.check_cube_size(cube_size)
      raise TypeError unless cube_size.is_a?(Integer)
      raise ArgumentError, 'Cubes of size smaller than 2 are not supported.' if cube_size < 2
    end

    def self.from_stickers(cube_size, stickers)
      CubeState.check_cube_size(cube_size)
      unless stickers.length == FACE_SYMBOLS.length
        raise ArgumentError, "Cubes must have #{FACE_SYMBOLS.length} sides."
      end

      unless stickers.all? { |p| p.length == cube_size && p.all? { |q| q.length == cube_size } }
        raise ArgumentError,
              "All sides of a #{cube_size}x#{cube_size} must be #{cube_size}x#{cube_size}."
      end

      stickers_hash = create_stickers_hash(stickers)
      new(Native::CubeState.new(cube_size, stickers_hash))
    end

    def self.create_stickers_hash(stickers)
      FACE_SYMBOLS.zip(stickers).to_h do |face_symbol, face_stickers|
        face = Face.for_face_symbol(face_symbol)
        face_hash = {
          stickers: face_stickers,
          # Note that in the ruby code, x and y are exchanged s.t. one can say bla[x][y],
          # but the C code does the more logical thing,
          # so we have to swap coordinates here.
          x_base_face_symbol: face.coordinate_index_base_face(1).face_symbol,
          y_base_face_symbol: face.coordinate_index_base_face(0).face_symbol
        }
        [face_symbol, face_hash]
      end
    end

    def initialize(native)
      raise TypeError unless native.is_a?(Native::CubeState)

      @native = native
    end

    def dup
      CubeState.new(@native.dup)
    end

    attr_reader :native

    def n
      @native.cube_size
    end

    def stickers; end

    def eql?(other)
      self.class.equal?(other.class) && @native == other.native
    end

    alias == eql?

    def hash
      @hash ||= [self.class, @native].hash
    end

    def rotation_algorithms
      Rotation::ALL_ROTATIONS.combination(2).reject do |r0, r1|
        r0.inverse == r1
      end.map { |rs| Algorithm.new(rs) } # rubocop:disable Style/MultilineBlockChain
    end

    def equal_modulo_rotations?(other)
      rotation_algorithms.any? { |r| r.apply_temporarily_to(self) { |state| state == other } }
    end

    # TODO: Get rid of this backwards compatibility artifact
    def sticker_array(face)
      raise TypeError unless face.is_a?(Face)

      @native.sticker_array(
        face.face_symbol,
        # Note that in the ruby code, x and y are exchanged s.t. one can say bla[x][y],
        # but the C code does the more logical thing,
        # so we have to swap coordinates here.
        face.coordinate_index_base_face(1).face_symbol,
        face.coordinate_index_base_face(0).face_symbol
      )
    end

    def to_s
      cube_string(self, :nocolor)
    end

    def colored_to_s
      cube_string(self, :color)
    end

    def [](coordinate)
      @native[coordinate.native]
    end

    def []=(coordinate, color)
      @native[coordinate.native] = color
    end
  end
end
