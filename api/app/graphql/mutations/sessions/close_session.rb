# frozen_string_literal: true

module Mutations
  module Sessions
    class CloseSession < Mutations::BaseMutation
      description "Close a session so it stops accepting new orders"

      argument :id, ID, required: true, description: "Session to close"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :session, Types::Objects::SessionType, null: true, description: "The closed session"

      def resolve(id:)
        session = find_owned_session!(id)
        session.close! if session.open?
        { session:, errors: [] }
      end
    end
  end
end
