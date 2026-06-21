# frozen_string_literal: true

module Types
  module Objects
    class SubscriptionType < BaseObject
      description "Realtime events delivered over ActionCable"

      field :order_added, subscription: ::Subscriptions::OrderAdded,
        description: "A guest placed an order in the watched session"
      field :order_updated, subscription: ::Subscriptions::OrderUpdated,
        description: "The watched order changed (status, photo, or queue position)"
      field :session_updated, subscription: ::Subscriptions::SessionUpdated,
        description: "The watched session was opened or closed"
    end
  end
end
