# frozen_string_literal: true

module Mutations
  module Orders
    class CompleteOrder < Mutations::BaseMutation
      description "Mark an order ready with a photo of the finished drink (host only)"

      argument :file, ::ApolloUploadServer::Upload, required: true, description: "Photo of the finished drink"
      argument :order_id, ID, required: true, description: "Order to complete"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :order, Types::Objects::OrderType, null: true, description: "The completed order"

      def resolve(order_id:, file:)
        order = find_owned_order!(order_id)
        order.completion_photo.attach(io: file, filename: file.original_filename, content_type: file.content_type)
        order.update!(status: :ready)
        trigger_order_updated(order)
        trigger_queue_refresh(order.session)
        { order:, errors: [] }
      end
    end
  end
end
