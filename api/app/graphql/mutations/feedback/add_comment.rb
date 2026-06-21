# frozen_string_literal: true

module Mutations
  module Feedback
    class AddComment < Mutations::BaseMutation
      description "Leave a comment about an order (guest, via order token)"

      argument :body, String, required: true, description: "The comment text"
      argument :order_token, String, required: true, description: "The order's guest token"

      field :comment, Types::Objects::CommentType, null: true, description: "The saved comment"
      field :errors, [ String ], null: false, description: "Validation errors, if any"

      def resolve(order_token:, body:)
        order = Order.find_by(guest_token: order_token)
        return { comment: nil, errors: [ "Order not found" ] } unless order

        comment = order.comments.build(body:)
        return { comment: nil, errors: comment.errors.full_messages } unless comment.save

        { comment:, errors: [] }
      end
    end
  end
end
