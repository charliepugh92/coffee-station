# frozen_string_literal: true

module Types
  module Objects
    class UserType < BaseObject
      description "A primary user — a coffee-station host"

      field :created_at, GraphQL::Types::ISO8601DateTime, null: false, description: "When the account was created"
      field :display_name, String, null: false, description: "Name shown to guests on the host's stations"
      field :email, String, null: false, description: "Login email"
      field :id, ID, null: false, description: "Unique user ID"
      field :sessions, [ UserSessionType ], null: false,
        description: "The host's signed-in devices, most recently active first"

      def sessions
        object.user_sessions.order(last_active_at: :desc, created_at: :desc)
      end
    end
  end
end
