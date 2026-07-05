# frozen_string_literal: true

describe AbstractMoveParser do
  let(:parser) { described_class.new }

  it 'raises NotImplementedError on abstract methods' do
    expect { parser.regexp }.to raise_error(NotImplementedError)
    expect { parser.parse_part_key('name') }.to raise_error(NotImplementedError)
    expect { parser.parse_move_part('name', 'str') }.to raise_error(NotImplementedError)
    expect { parser.move_type_creators }.to raise_error(NotImplementedError)
  end

  it 'raises ArgumentError on invalid move formats in parse_move' do
    subclass =
      Class.new(described_class) do
        def regexp
          /R/
        end
      end
    subclass_instance = subclass.new
    expect { subclass_instance.parse_move('RU') }.to raise_error(ArgumentError)
  end

  it 'raises ArgumentError when no move type creator applies' do
    subclass =
      Class.new(described_class) do
        def regexp
          /R/
        end

        def parse_part_key(name)
          name
        end

        def parse_move_part(_name, string)
          string
        end

        def move_type_creators
          []
        end
      end
    subclass_instance = subclass.new
    expect { subclass_instance.parse_move('R') }.to raise_error(ArgumentError)
  end
end
