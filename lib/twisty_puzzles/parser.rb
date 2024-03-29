# frozen_string_literal: true

require 'twisty_puzzles/algorithm'
require 'twisty_puzzles/commutator'
require 'twisty_puzzles/cube_move_parser'
require 'twisty_puzzles/skewb_move_parser'
require 'twisty_puzzles/twisty_puzzles_error'

module TwistyPuzzles # rubocop:disable Style/Documentation
  class CommutatorParseError < TwistyPuzzlesError
  end

  # Parser for commutators and algorithms.
  class Parser # rubocop:disable Metrics/ClassLength
    OPENING_BRACKET = '['
    OPENING_PAREN = '('
    CLOSING_BRACKET = ']'
    CLOSING_PAREN = ')'
    SLASH = '/'
    COMMA = ','
    PLUS = '+'
    SETUP_SEPARATORS = %w[; :].freeze
    PURE_SEPARATORS = [SLASH, COMMA].freeze
    SEPARATORS = (SETUP_SEPARATORS + PURE_SEPARATORS).freeze

    TIMES = '*'

    def initialize(alg_string, move_parser)
      @alg_string = alg_string
      @scanner = StringScanner.new(alg_string)
      @move_parser = move_parser
    end

    def parse_open_paren
      complain('beginning of trigger') unless @scanner.getch == OPENING_PAREN
    end

    def parse_close_paren
      complain('end of trigger') unless @scanner.getch == CLOSING_PAREN
    end

    def parse_times
      complain('times symbol of multiplier') unless @scanner.getch == TIMES
    end

    def parse_factor
      number = @scanner.scan(/\d+/)
      complain('factor of multiplier') unless number
      Integer(number, 10)
    end

    def parse_multiplier
      skip_spaces
      parse_times
      skip_spaces
      parse_factor
    end

    def parse_trigger
      parse_open_paren
      skip_spaces
      moves = parse_moves_with_triggers
      skip_spaces
      parse_close_paren
      skip_spaces
      case @scanner.peek(1)
      when TIMES
        moves * parse_multiplier
      when ('0'..'9')
        moves * parse_factor
      else
        moves
      end
    end

    # Parses at least one move and allows for triggers in parentheses.
    def parse_moves_with_triggers
      skip_spaces
      if @scanner.peek(1) == OPENING_PAREN
        parse_trigger + parse_moves_with_triggers
      else
        parse_moves
      end
    end

    # Parses at least one move.
    def parse_nonempty_moves_with_triggers
      moves = parse_moves_with_triggers
      complain('move') if moves.empty?
      moves
    end

    # Parses a series of moves.
    def parse_moves
      moves = []
      while (m = begin skip_spaces; parse_move_internal end)
        moves.push(m)
      end
      skip_spaces
      moves *= parse_multiplier if @scanner.peek(1) == TIMES
      Algorithm.new(moves)
    end

    def complain(parsed_object)
      raise CommutatorParseError, <<~ERROR.chomp
        Couldn't parse #{parsed_object} here:
          #{@alg_string}
          #{' ' * @scanner.pos}^"
      ERROR
    end

    def check_eos(parsed_object)
      complain("end of #{parsed_object}") unless @scanner.eos?
    end

    def parse_open_bracket
      complain('beginning of commutator') unless @scanner.getch == OPENING_BRACKET
    end

    def parse_close_bracket
      complain('end of commutator') unless @scanner.getch == CLOSING_BRACKET
    end

    def parse_commutator
      skip_spaces
      if @scanner.peek(1) == OPENING_BRACKET
        parse_commutator_internal
      else
        parse_commutator_no_brackets
      end
    end

    def parse_commutator_no_brackets
      setup_or_first_part_or_algorithm = parse_moves_with_triggers
      skip_spaces
      if @scanner.eos? || !SEPARATORS.include?(@scanner.peek(1))
        return FakeCommutator.new(setup_or_first_part_or_algorithm)
      end

      setup_or_first_part = setup_or_first_part_or_algorithm
      complain('move') if setup_or_first_part.empty?
      separator = parse_separator
      comm = parse_commutator_internal_after_separator(setup_or_first_part, separator)
      skip_spaces
      return parse_commutator_sum_with_prefix(comm) if @scanner.peek(1) == PLUS

      complain('end of commutator') unless @scanner.eos?
      comm
    end

    def parse_algorithm
      skip_spaces
      parse_moves_with_triggers
    end

    def parse_setup_commutator_inner
      skip_spaces
      if @scanner.peek(1) == OPENING_BRACKET
        parse_pure_commutator
      else
        parse_pure_commutator_no_brackets
      end
    end

    def parse_pure_commutator
      skip_spaces
      parse_open_bracket
      first_part = parse_nonempty_moves_with_triggers
      skip_spaces
      separator = parse_pure_separator
      second_part = parse_nonempty_moves_with_triggers
      skip_spaces
      parse_close_bracket
      pseudo_pure_commutator(separator, first_part, second_part)
    end

    def parse_pure_commutator_no_brackets
      first_part_or_algorithm = parse_moves_with_triggers
      skip_spaces
      if @scanner.eos? || !PURE_SEPARATORS.include?(@scanner.peek(1))
        return FakeCommutator.new(first_part_or_algorithm)
      end

      first_part = first_part_or_algorithm
      complain('move') if first_part.empty?
      separator = parse_pure_separator
      second_part = parse_nonempty_moves_with_triggers
      skip_spaces
      pseudo_pure_commutator(separator, first_part, second_part)
    end

    def parse_pure_separator
      separator = @scanner.getch
      complain('middle of pure commutator') unless PURE_SEPARATORS.include?(separator)
      separator
    end

    def parse_commutator_internal_after_separator(setup_or_first_part, separator)
      if SETUP_SEPARATORS.include?(separator)
        inner_commutator = parse_setup_commutator_inner
        SetupCommutator.new(setup_or_first_part, inner_commutator)
      elsif PURE_SEPARATORS.include?(separator)
        second_part = parse_nonempty_moves_with_triggers
        pseudo_pure_commutator(separator, setup_or_first_part, second_part)
      else
        complain('end of setup or middle of pure commutator') unless @scanner.eos?
      end
    end

    def pseudo_pure_commutator(separator, first_part, second_part)
      if separator == COMMA
        PureCommutator.new(first_part, second_part)
      elsif separator == SLASH
        SlashCommutator.new(first_part, second_part)
      else
        complain('middle of pure commutator') unless PURE_SEPARATORS.include?(separator)
      end
    end

    def parse_separator
      separator = @scanner.getch
      complain('separator between commutator parts') unless SEPARATORS.include?(separator)
      separator
    end

    def parse_commutator_internal
      skip_spaces
      parse_open_bracket
      setup_or_first_part = parse_nonempty_moves_with_triggers
      skip_spaces
      separator = parse_separator
      comm = parse_commutator_internal_after_separator(setup_or_first_part, separator)
      skip_spaces
      parse_close_bracket
      skip_spaces
      return parse_commutator_sum_with_prefix(comm) if @scanner.peek(1) == PLUS

      complain('end of commutator') unless @scanner.eos?
      comm
    end

    def parse_plus
      complain('operator of commutator sequence') unless @scanner.getch == PLUS
    end

    def parse_commutator_sum_with_prefix(commutator)
      skip_spaces
      parse_plus
      skip_spaces
      CommutatorSequence.new([commutator, parse_commutator])
    end

    def parse_move_internal
      move = @scanner.scan(@move_parser.regexp)
      return unless move

      @move_parser.parse_move(move)
    end

    def skip_spaces
      @scanner.skip(/\s+/)
    end
  end

  def parse_commutator(alg_string, complete_parse: true)
    parser = Parser.new(alg_string, CubeMoveParser::INSTANCE)
    commutator = parser.parse_commutator
    parser.check_eos('commutator') if complete_parse
    commutator
  end

  def parse_cube_algorithm(alg_string, complete_parse: true)
    parser = Parser.new(alg_string, CubeMoveParser::INSTANCE)
    algorithm = parser.parse_algorithm
    parser.check_eos('algorithm') if complete_parse
    algorithm
  end

  def parse_cube_move(move_string)
    CubeMoveParser::INSTANCE.parse_move(move_string)
  end

  alias parse_algorithm parse_cube_algorithm
  alias parse_move parse_cube_move

  def parse_skewb_algorithm(alg_string, notation, complete_parse: true)
    parser = Parser.new(alg_string, SkewbMoveParser.new(notation))
    algorithm = parser.parse_algorithm
    parser.check_eos('algorithm') if complete_parse
    algorithm
  end

  def parse_skewb_move(move_string, notation)
    SkewbMoveParser.new(notation).parse_move(move_string)
  end
end
