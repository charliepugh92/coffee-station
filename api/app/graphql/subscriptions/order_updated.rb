# frozen_string_literal: true

module Subscriptions
  class OrderUpdated < Subscriptions::BaseSubscription
    description "Fires on a guest's order page when its status, photo, or queue position changes"

    argument :order_token, String, required: true,
      description: "The order's guest token (the guest's capability to watch this order)"

    field :order, Types::Objects::OrderType, null: false, description: "The updated order"

    def subscribe(order_token:)
      raise GraphQL::ExecutionError, "Order not found" unless Order.exists?(guest_token: order_token)

      :no_response
    end

    def update(order_token:)
      { order: object }
    end
  end
end
