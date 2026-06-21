# frozen_string_literal: true

module Subscriptions
  class OrderAdded < Subscriptions::BaseSubscription
    description "Fires on the host's live board when a guest places an order"

    argument :session_token, String, required: true,
      description: "The session share token (the host's capability to watch this board)"

    field :order, Types::Objects::OrderType, null: false, description: "The newly placed order"

    # The WebSocket connection is anonymous, so we scope by possession of the
    # unguessable share token rather than current_user.
    def subscribe(session_token:)
      raise GraphQL::ExecutionError, "Session not found" unless Session.exists?(share_token: session_token)

      :no_response
    end

    def update(session_token:)
      { order: object }
    end
  end
end
