# frozen_string_literal: true

module Types
  module Objects
    class UserType < BaseObject
      description "A primary user — a coffee-station host"

      field :created_at, GraphQL::Types::ISO8601DateTime, null: false, description: "When the account was created"
      field :display_name, String, null: false, description: "Name shown to guests on the host's stations"
      field :email, String, null: false, description: "Login email"
      field :id, ID, null: false, description: "Unique user ID"
    end
  end
end
