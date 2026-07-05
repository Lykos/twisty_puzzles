# frozen_string_literal: true

describe LetterScheme do |_clazz|
  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:letter) { letter_scheme.alphabet.sample }

  it 'finds the corner with the right letter' do
    corner = letter_scheme.for_letter(Corner, letter)
    expect(letter_scheme.letter(corner)).to be == letter
  end

  it 'finds the edge with the right letter' do
    edge = letter_scheme.for_letter(Edge, letter)
    expect(letter_scheme.letter(edge)).to be == letter
  end

  it 'finds the wing with the right letter' do
    wing = letter_scheme.for_letter(Wing, letter)
    expect(letter_scheme.letter(wing)).to be == letter
  end

  it 'finds the midge with the right letter' do
    midge = letter_scheme.for_letter(Midge, letter)
    expect(letter_scheme.letter(midge)).to be == letter
  end

  it 'finds the tcenter with the right letter' do
    tcenter = letter_scheme.for_letter(TCenter, letter)
    expect(letter_scheme.letter(tcenter)).to be == letter
  end

  it 'finds the xcenter with the right letter' do
    xcenter = letter_scheme.for_letter(XCenter, letter)
    expect(letter_scheme.letter(xcenter)).to be == letter
  end

  it 'raises NotImplementedError on abstract methods during base initialization' do
    expect { described_class.new }.to raise_error(NotImplementedError)
  end

  it 'raises NotImplementedError on abstract methods in subclasses' do
    subclass =
      Class.new(described_class) do
        def alphabet
          ['a']
        end
      end
    expect { subclass.new.canonicalize_letter('a') }.to raise_error(NotImplementedError)
  end

  it 'validates letter correctly' do
    expect(letter_scheme.valid_letter?('a')).to be(true)
    expect(letter_scheme.valid_letter?('A')).to be(true)
    expect(letter_scheme.valid_letter?('z')).to be(false)
  end

  it 'parses part correctly' do
    expect(letter_scheme.parse_part(Corner, 'a')).to eq(letter_scheme.for_letter(Corner, 'a'))
    expect(letter_scheme.parse_part(Corner, 'UFL')).to eq(Corner.for_face_symbols(%i[U F L]))
  end

  it 'provides shoot letters and default buffers on BernhardLetterScheme' do
    expect(letter_scheme.shoot_letters(Corner)).to be_an(Array)
    expect(letter_scheme.default_buffer(Corner)).to eq(Corner.for_face_symbols(%i[U L B]))
  end

  it 'raises error on uncanonical alphabet letters during initialization' do
    subclass =
      Class.new(described_class) do
        def alphabet
          ['A']
        end

        def canonicalize_letter(letter)
          letter.downcase
        end
      end
    expect { subclass.new }.to raise_error(/Uncanonical letter/)
  end
end
