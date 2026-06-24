# frozen_string_literal: true

module Mutations
  module Orders
    class CompleteOrder < Mutations::BaseMutation
      description "Mark an order ready, optionally with a photo of the finished drink (host only)"

      argument :file, ::ApolloUploadServer::Upload, required: false, description: "Optional photo of the finished drink"
      argument :order_id, ID, required: true, description: "Order to complete"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :order, Types::Objects::OrderType, null: true, description: "The completed order"

      def resolve(order_id:, file: nil)
        order = find_owned_order!(order_id)

        # Flip status and notify the guest FIRST, before the memory-heavy photo
        # attach. On the constrained tier the attach can OOM-kill the worker; doing
        # it last means a crash still leaves a readied, already-notified order
        # rather than losing both. The photo is a best-effort bonus on top.
        order.update!(status: :ready)
        trigger_order_updated(order)
        trigger_queue_refresh(order.session)

        attach_completion_photo(order, file) if file

        { order:, errors: [] }
      end

      private

      # Best-effort: the order is already ready and the guest already pushed, so a
      # failed attach must not 500 the mutation or roll back the hand-off. Re-broadcast
      # (without a second push) so the live page shows the photo once it lands.
      def attach_completion_photo(order, file)
        order.completion_photo.attach(io: file, filename: file.original_filename, content_type: file.content_type)
        broadcast_order_updated(order)
      rescue StandardError => e
        Rails.logger.error("[complete_order] photo attach failed for order #{order.id}: #{e.class}: #{e.message}")
      end
    end
  end
end
