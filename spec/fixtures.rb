shared_context :user do
  let(:user) do
    user = User.find_or_initialize_by(
      name: 'abc'
    )
    user.update(
      password: 'password',
      password_confirmation: 'password'
    )
    user.save!
    user
  end  
end

shared_context :eve do
  let(:eve) do
    user = User.find_or_initialize_by(
      name: 'eve'
    )
    user.update(
      password: 'password',
      password_confirmation: 'password'
    )
    user.save!
    user
  end  
end

shared_context :admin do
  let(:admin) do
    user = User.find_or_initialize_by(
      name: 'admin'
    )
    user.update(
      password: 'password',
      password_confirmation: 'password',
      admin: true
    )
    user.save!
    user
  end  
end

shared_context :mode do
  include_context :user

  let(:mode) do
    mode = user.modes.find_or_initialize_by(
      name: 'test_mode'
    )
    mode.update(
      show_input_mode: :name,
      mode_type: :floating_2flips,
      goal_badness: 1.0,
      cube_size: 3,
      known: false
    )
    mode.save!
    mode
  end
end

shared_context :input do
  include_context :mode

  let(:input) do
    mode.inputs.find_or_create_by!(input_representation: CubeTrainer::LetterPair.new(%w(a b)))
  end
end

shared_context :result do
  include_context :input

  let(:result) do
    input.result&.destroy!
    partial_result = CubeTrainer::Training::PartialResult.new(10)
    result = Result.from_input_and_partial(input, partial_result)
    result.save!
    result
  end
end