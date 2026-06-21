# frozen_string_literal: true

module Mutations
  module Orders
    class UpdateOrderStatus < Mutations::BaseMutation
      description "Advance an order's status (host only)"

      argument :order_id, ID, required: true, description: "Order to update"
      argument :status, Types::Enums::OrderStatusEnum, required: true, description: "New status"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :order, Types::Objects::OrderType, null: true, description: "The updated order"

      def resolve(order_id:, status:)
        order = find_owned_order!(order_id)
        order.update!(status:)
        trigger_order_updated(order)
        trigger_queue_refresh(order.session)
        { order:, errors: [] }
      end
    end
  end
end
