# frozen_string_literal: true

module Subscriptions
  class SessionUpdated < Subscriptions::BaseSubscription
    description "Fires when a session is opened or closed (read by both the host board and guest pages)"

    argument :session_token, String, required: true, description: "The session share token"

    field :session, Types::Objects::SessionType, null: false, description: "The updated session"

    def subscribe(session_token:)
      raise GraphQL::ExecutionError, "Session not found" unless Session.exists?(share_token: session_token)

      :no_response
    end

    def update(session_token:)
      { session: object }
    end
  end
end
