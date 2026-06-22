# frozen_string_literal: true

module Mutations
  module Orders
    class DeleteOrder < Mutations::BaseMutation
      description "Delete an order (host only) — also purges its completion photo and feedback"

      argument :order_id, ID, required: true, description: "Order to delete"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :success, Boolean, null: false, description: "Whether the operation succeeded"

      def resolve(order_id:)
        order = find_owned_order!(order_id)
        session = order.session
        # destroy cascades to order_selections, rating and comments, and
        # ActiveStorage purges the attached completion_photo blob.
        order.destroy
        # Remaining queued orders shift up, so re-notify their guests.
        trigger_queue_refresh(session)
        { success: true, errors: [] }
      end
    end
  end
end
