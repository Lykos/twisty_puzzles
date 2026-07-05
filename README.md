[![Ruby](https://github.com/Lykos/twisty_puzzles/workflows/Ruby/badge.svg)](https://github.com/Lykos/twisty_puzzles/actions/workflows/ruby.yml)
[![Rubocop](https://github.com/Lykos/twisty_puzzles/workflows/Rubocop/badge.svg)](https://github.com/Lykos/twisty_puzzles/actions/workflows/rubocop.yml)
[![cpp-linter](https://github.com/Lykos/twisty_puzzles/workflows/c-linter/badge.svg)](https://github.com/Lykos/twisty_puzzles/actions/workflows/clinter.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Gem Version](https://badge.fury.io/rb/twisty_puzzles.svg)](https://badge.fury.io/rb/twisty_puzzles)

# Twisty Puzzles
Gem for my cube_trainer rails app. Some things are better left in a separate gem with no rails, e.g. native extensions. The main purpose is to support my Rails app, but if it's useful for someone else, feel free to use it at your own risk.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'twisty_puzzles'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install twisty_puzzles

## Usage

Here are some basic examples of how to use the `twisty_puzzles` gem:

### 1. Parsing Algorithms and Moves

You can parse standard Rubik's Cube algorithms or individual moves using the module helper methods:

```ruby
require 'twisty_puzzles'

# Parse a full algorithm (e.g. a Sledgehammer)
algorithm = TwistyPuzzles.parse_algorithm("R' F R F'")
puts "Parsed algorithm length: #{algorithm.length}" # => 4

# Or parse individual moves
move = TwistyPuzzles.parse_move("U2")
puts move.class # => TwistyPuzzles::CubeMove
```

### 2. Creating and Applying Moves to a Cube State

You can instantiate a solved cube state (supporting arbitrary dimensions, e.g. 3x3x3, 4x4x4, etc.) and apply algorithms to manipulate its state:

```ruby
# Get a standard solved 3x3x3 CubeState under the WCA color scheme
cube_state = TwistyPuzzles::ColorScheme::WCA.solved_cube_state(3)

# Apply the parsed algorithm
algorithm.apply_to(cube_state)

# Check the color of a specific sticker (coordinate) on the U face
face = TwistyPuzzles::Face::U
# Coordinate from U face, 3x3x3 cube size, x=0, y=0
coordinate = TwistyPuzzles::Coordinate.from_indices(face, 3, 0, 0)
puts "Sticker color at (0, 0) on U Face: #{cube_state[coordinate]}"
```

### 3. Parsing and Working with Skewb puzzles

`twisty_puzzles` also supports Skewb puzzles using different notations (like Sarah's notation):

```ruby
# Get Sarah's notation for Skewb
skewb_notation = TwistyPuzzles::SkewbNotation.sarah

# Parse a skewb algorithm
skewb_algorithm = TwistyPuzzles.parse_skewb_algorithm("R U' R' U", skewb_notation)

# Create a solved Skewb state
skewb_state = TwistyPuzzles::ColorScheme::WCA.solved_skewb_state

# Apply the skewb algorithm
skewb_algorithm.apply_to(skewb_state)
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rake spec` to run the tests. You can also run `bundle exec bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `lib/twisty_puzzles/version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Lykos/twisty_puzzles.
