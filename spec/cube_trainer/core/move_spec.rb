require 'cube_trainer/color_scheme'
require 'cube_trainer/core/move'
require 'cube_trainer/core/cube_state'
require 'cube_trainer/core/skewb_state'
require 'cube_trainer/core/cube_print_helper'
require 'cube_trainer/core/parser'

describe Move do

  let (:color_scheme) { ColorScheme::BERNHARD }
  
  it 'should invert M slices correctly' do
    expect(parse_move("M").inverse).to be == parse_move("M'")
    expect(parse_move("M'").inverse).to be == parse_move("M")
    expect(parse_move("S").inverse).to be == parse_move("S'")
    expect(parse_move("S'").inverse).to be == parse_move("S")
    expect(parse_move("E").inverse).to be == parse_move("E'")
    expect(parse_move("E'").inverse).to be == parse_move("E")
  end

  it 'should rotate cubes correctly' do
    state = color_scheme.solved_cube_state(3)
    parse_fixed_corner_skewb_algorithm("x y z' y'").apply_temporarily_to(state) do
      expect(state).to be == color_scheme.solved_cube_state(3)
    end
  end

  it 'should rotate skewbs correctly' do
    skewb_state = color_scheme.solved_skewb_state
    parse_fixed_corner_skewb_algorithm("x").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == SkewbState.for_solved_colors({U: :red, F: :white, R: :green, L: :blue, B: :yellow, D: :orange})
    end
    parse_fixed_corner_skewb_algorithm("y").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == SkewbState.for_solved_colors({U: :yellow, F: :green, R: :orange, L: :red, B: :blue, D: :white})
    end
    parse_fixed_corner_skewb_algorithm("z").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == SkewbState.for_solved_colors({U: :blue, F: :red, R: :yellow, L: :white, B: :orange, D: :green})
    end
    parse_fixed_corner_skewb_algorithm("x y z' y'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("R y U' x'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("U y L' x' y2").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("L y B' y'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("B y R' y'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("R z B' y2 z y2").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("U z L' y'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("L z R' z2 y").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("B z U' z'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("R x U' z y2").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("U x B' x'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("L x R' z'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("B x L' x'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
  end
  
end