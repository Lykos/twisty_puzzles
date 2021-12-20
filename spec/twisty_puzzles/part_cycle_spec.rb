# frozen_string_literal: true

require 'rantly'
require 'rantly/rspec_extensions'
require 'rantly/shrinks'

describe PartCycle do
  it 'can be serialized and deserialized' do
    property_of do
      Rantly { part_cycle }
    end.check do |c|
      expect(PartCycle.from_raw_data(c.to_raw_data)).to eq(c)
    end
  end

  it 'can be inverted and it still starts with the same part' do
    property_of do
      Rantly { part_cycle }
    end.check do |c|
      expect(c.inverse.parts.first).to eq(c.parts.first)
    end
  end

  it 'is the inverse of its inverse' do
    property_of do
      Rantly { part_cycle }
    end.check do |c|
      expect(c.inverse.inverse).to eq(c)
    end
  end

  it 'is equivalent to itself' do
    property_of do
      Rantly { part_cycle }
    end.check do |c|
      expect(c.equivalent?(c)).to be(true)
    end
  end

  it 'is equivalent to a rotation of itself' do
    property_of do
      Rantly { part_cycle }
    end.check do |c|
      expect(c.equivalent?(c.rotate_by(1))).to be(true)
    end
  end

  it 'is equivalent to a per-element rotation of itself' do
    property_of do
      Rantly { part_cycle }
    end.check do |c|
      expect(c.equivalent?(c.map_rotate_by(1))).to be(true)
    end
  end

  it 'returns an equivalent cycle starting with the part given in start_with' do
    property_of do
      Rantly do
        c = part_cycle
        p = choose(*c.parts)
        r = choose(*p.rotations)
        [c, r]
      end
    end.check do |c, p|
      expect(c.start_with(p).equivalent?(c)).to be(true)
    end
  end
end
