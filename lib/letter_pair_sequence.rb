require 'letter_pair'

module CubeTrainer

  class LetterPairSequence

    SEPARATOR = ';'

    raise if SEPARATOR == LetterPair::SEPARATOR

    def initialize(letter_pairs)
      raise ArgumentError unless letter_pairs.all? { |ls| ls.kind_of?(LetterPair) }
      raise ArgumentError, "Invalid letter '#{SEPARATOR}' in letter pair #{letters.join(" ")}." if letter_pairs.any? { |ls| ls.letters.include?(SEPARATOR) }
      @letter_pairs = letter_pairs
    end

    attr_reader :letter_pairs
  
    # Encoding for YAML (and possibly others)
    def encode_with(coder)
      coder['letters'] = @letters
    end
  
    # Construct from data stored in the db.
    def self.from_raw_data(data)
      LetterSequence.new(data.split(SEPARATOR).map { |d| LetterSequence.from_raw_data(d) })
    end

    def has_any_letter?(letters)
      @letter_pairs.any? { |ls| ls.has_any_letter?(letters) }
    end
  
    # Serialize to data stored in the db.
    def to_raw_data
      @letter_pairs.join(SEPARATOR)
    end
  
    def eql?(other)
      self.class.equal?(other.class) && @letter_pairs == other.letter_pairs
    end
  
    alias == eql?
  
    def hash
      @letter_pairs.hash
    end
  
    def to_s
      @to_s ||= @letter_pairs.join(SEPARATOR)
    end
  
  end

end