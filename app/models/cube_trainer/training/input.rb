# frozen_string_literal: true

module CubeTrainer
  module Training
    # Input that is used as for training for the user.
    # The part of the result that is already fixed after sampling.
    class Input < ApplicationRecord
      attribute :mode, :symbol
      attribute :input_representation, :input_representation
    end
  end
end
