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
        order = session.orders.build(guest_name: attrs.guest_name, notes: attrs.notes)
        order.base_option = valid_option(station, attrs.base_option_id) if attrs.base_option_id
        order.menu_preset = station.menu_presets.find_by(id: attrs.menu_preset_id) if attrs.menu_preset_id

        return error(order.errors.full_messages) unless order.save

        order.customization_option_ids = sanitize_options(station, attrs.option_ids) if attrs.option_ids
        { order:, guest_token: order.guest_token, errors: [] }
      end

      private

      def error(messages)
        { order: nil, guest_token: nil, errors: Array(messages) }
      end

      def station_option_ids(station)
        CustomizationOption.where(customization_category_id: station.customization_categories.select(:id)).ids
      end

      def sanitize_options(station, ids)
        ids.map(&:to_i) & station_option_ids(station)
      end

      def valid_option(station, id)
        CustomizationOption.where(id: station_option_ids(station)).find_by(id:)
      end
    end
  end
end
