# frozen_string_literal: true

module Types
  module Interfaces
    module NodeType
      include Types::Interfaces::BaseInterface
      description "An object with a globally unique ID"
      # Used internally by graphql-ruby's Relay node resolution.
      include GraphQL::Types::Relay::NodeBehaviors
    end
  end
end
