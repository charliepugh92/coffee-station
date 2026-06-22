# frozen_string_literal: true

module Mutations
  module Orders
    class Reorder < Mutations::BaseMutation
      description "Place a fresh order cloning a past one's selections (guest, via order token)"

      argument :order_token, String, required: true, description: "A past order's guest token"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :guest_token, String, null: true, description: "Capability token for the new order — store it client-side"
      field :order, Types::Objects::OrderType, null: true, description: "The new order"

      def resolve(order_token:)
        prior = Order.find_by(guest_token: order_token)
        return error("Order not found") unless prior

        session = prior.station.open_session
        return error("This station is closed") unless session

        order = session.orders.create!(
          guest_name: prior.guest_name,
          notes: prior.notes,
          base_id: prior.base_id,
          menu_preset_id: prior.menu_preset_id
        )
        order.customization_option_ids = prior.customization_option_ids
        trigger_order_added(order)
        { order:, guest_token: order.guest_token, errors: [] }
      end

      private

      def error(message)
        { order: nil, guest_token: nil, errors: [ message ] }
      end
    end
  end
end
