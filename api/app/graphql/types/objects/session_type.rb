# frozen_string_literal: true

module Types
  module Objects
    class SessionType < BaseObject
      description "An open (or closed) period during which a station accepts orders"

      field :closed_at, GraphQL::Types::ISO8601DateTime, null: true, description: "When the session was closed"
      field :id, ID, null: false, description: "Unique session ID"
      field :opened_at, GraphQL::Types::ISO8601DateTime, null: true, description: "When the session was opened"
      field :orders, [ OrderType ], null: false,
        description: "Orders placed in this session (visible only to the owning host)"
      field :share_token, String, null: true,
        description: "Unguessable share-link key — visible only to the owning host"
      field :station, "Types::Objects::StationType", null: false, description: "The station this session belongs to"
      field :status, Types::Enums::SessionStatusEnum, null: false, description: "Open or closed"

      # Guests load a session by its share token (which they already hold in the
      # URL); never echo the token back to them.
      def share_token
        return nil unless owner_viewing?

        object.share_token
      end

      def orders
        return [] unless owner_viewing?

        object.orders.order(:created_at)
      end

      private

      def owner_viewing?
        context[:current_user] && object.station_user_id == context[:current_user].id
      end
    end
  end
end
