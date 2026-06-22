# frozen_string_literal: true

module Mutations
  module Users
    class RevokeSession < Mutations::BaseMutation
      description "Sign out one of the current host's devices by revoking its session"

      argument :session_id, ID, required: true, description: "The UserSession id to revoke"

      field :errors, [ String ], null: false, description: "Errors, if any"
      field :success, Boolean, null: false, description: "Whether the session was revoked"

      def resolve(session_id:)
        require_auth!
        session = current_user.user_sessions.find_by(id: session_id)
        return { success: false, errors: [ "Session not found" ] } unless session

        session.destroy
        { success: true, errors: [] }
      end
    end
  end
end
