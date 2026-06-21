# frozen_string_literal: true

module Mutations
  module Feedback
    class RateOrder < Mutations::BaseMutation
      description "Leave (or update) a 1–5 star rating for an order (guest, via order token)"

      argument :order_token, String, required: true, description: "The order's guest token"
      argument :stars, Integer, required: true, description: "Star rating, 1 to 5"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :rating, Types::Objects::RatingType, null: true, description: "The saved rating"

      def resolve(order_token:, stars:)
        order = Order.find_by(guest_token: order_token)
        return { rating: nil, errors: [ "Order not found" ] } unless order

        rating = order.rating || order.build_rating
        rating.stars = stars
        return { rating: nil, errors: rating.errors.full_messages } unless rating.save

        { rating:, errors: [] }
      end
    end
  end
end
