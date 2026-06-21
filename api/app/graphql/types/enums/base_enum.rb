# frozen_string_literal: true

module Types
  module Enums
    class BaseEnum < GraphQL::Schema::Enum
      class << self
        private

        # Build GraphQL enum values from a Rails model enum so the two stay in
        # lockstep. e.g. generate_from_rails_enum(Order.statuses) yields PENDING,
        # IN_PROGRESS, ... mapped back to their string keys.
        def generate_from_rails_enum(enum)
          enum.each_key do |enum_val|
            value enum_val.upcase, value: enum_val
          end
        end
      end
    end
  end
end
