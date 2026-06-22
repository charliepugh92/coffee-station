# frozen_string_literal: true

module Mutations
  module Orders
    class CreateOrder < Mutations::BaseMutation
      description "Place an order against an open session (guest — no login)"

      argument :attrs, Types::InputObjects::OrderInput, required: true, description: "The order contents"
      argument :session_token, String, required: true, description: "The session share token from the guest link"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :guest_token, String, null: true,
        description: "Capability token for this order — returned once, store it client-side"
      field :order, Types::Objects::OrderType, null: true, description: "The placed order"

      def resolve(session_token:, attrs:)
        session = Session.find_by(share_token: session_token)
        return error("This coffee link isn't valid") unless session
        return error("This station is closed") unless session.accepting_orders?

        station = session.station
        base = station.bases.find_by(id: attrs.base_id) if attrs.base_id
        order = session.orders.build(guest_name: attrs.guest_name, notes: attrs.notes, base:)
        order.menu_preset = station.menu_presets.find_by(id: attrs.menu_preset_id) if attrs.menu_preset_id

        return error(order.errors.full_messages) unless order.save

        order.customization_option_ids = sanitize_options(station, attrs.option_ids, base) if attrs.option_ids
        trigger_order_added(order)
        { order:, guest_token: order.guest_token, errors: [] }
      end

      private

      def error(messages)
        { order: nil, guest_token: nil, errors: Array(messages) }
      end

      # Options the order may include: scoped to the categories enabled by the
      # chosen base, or the station's whole menu when no base was picked.
      def station_option_ids(station, base = nil)
        categories = base ? base.customization_categories : station.customization_categories
        CustomizationOption.where(customization_category_id: categories.select(:id)).ids
      end

      def sanitize_options(station, ids, base = nil)
        ids.map(&:to_i) & station_option_ids(station, base)
      end
    end
  end
end
