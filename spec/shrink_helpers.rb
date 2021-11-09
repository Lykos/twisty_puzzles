# frozen_string_literal: true

require 'rantly/shrinks'

module TwistyPuzzles
  class Algorithm
    def shrink
      a = Algorithm.new(@moves[0...position] + @moves[position + 1..])
      @position = position - 1
      a
    end

    def position
      @position ||= length - 1
    end

    def retry?
      position >= 0
    end

    def shrinkable?
      !empty?
    end
  end

  class PartCycle
    def shrink
      a = PartCycle.new(@parts[0...position] + @parts[position + 1..])
      @position = position - 1
      a
    end

    def position
      @position ||= length - 1
    end

    def retry?
      position >= 0
    end

    def shrinkable?
      length > 1
    end
  end
end
