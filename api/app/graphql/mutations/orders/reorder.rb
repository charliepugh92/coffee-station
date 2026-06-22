# frozen_string_literal: true

module Mutations
  module Orders
    class Reorder < Mutations::BaseMutation
      description "Place a fresh order from a past one's remembered selections (guest, via order token)"

      argument :order_token, String, required: true, description: "A past order's guest token"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :guest_token, String, null: true, description: "Capability token for the new order — store it client-side"
      field :order, Types::Objects::OrderType, null: true, description: "The new order"
      field :warnings, [ String ], null: false,
        description: "Parts of the original order that the current menu can no longer reproduce"

      # Rebuilds the order from the prior one's `memory` snapshot, matching each
      # base/preset/option against the current menu by id first, then by name,
      # and reporting whatever can't be reproduced as a warning.
      def resolve(order_token:)
        prior = Order.find_by(guest_token: order_token)
        return error("Order not found") unless prior

        session = prior.station.open_session
        return error("This station is closed") unless session

        station = session.station
        memory = prior.memory || {}
        warnings = []

        base = resolve_base(station, memory["base"], warnings)
        preset = resolve_preset(station, memory["preset"], warnings)
        options = resolve_options(station, base, Array(memory["groups"]), warnings)

        order = session.orders.create!(
          guest_name: prior.guest_name,
          notes: prior.notes,
          base:,
          menu_preset: preset,
          memory: Order.build_memory(base:, preset:, options:)
        )
        trigger_order_added(order)
        { order:, guest_token: order.guest_token, warnings:, errors: [] }
      end

      private

      def error(message)
        { order: nil, guest_token: nil, warnings: [], errors: [ message ] }
      end

      def resolve_base(station, snap, warnings)
        return nil if snap.blank?

        base = station.bases.find_by(id: snap["id"]) || station.bases.find_by(name: snap["name"])
        warnings << "Base \"#{snap['name']}\" is no longer available" unless base
        base
      end

      def resolve_preset(station, snap, warnings)
        return nil if snap.blank?

        preset = station.menu_presets.find_by(id: snap["id"]) || station.menu_presets.find_by(name: snap["name"])
        warnings << "Preset \"#{snap['name']}\" is no longer available" unless preset
        preset
      end

      # Only options within the chosen base's categories (or the whole menu when
      # there's no base) are eligible — the same scoping create_order enforces.
      def resolve_options(station, base, groups, warnings)
        categories = base ? base.customization_categories : station.customization_categories
        scope = CustomizationOption.where(customization_category_id: categories.select(:id))
                                   .includes(:customization_category)

        groups.flat_map do |group|
          Array(group["options"]).filter_map do |snap|
            option = scope.find_by(id: snap["id"]) ||
                     scope.joins(:customization_category)
                          .find_by(name: snap["name"], customization_categories: { name: group["category"] })
            warnings << "#{group['category']}: \"#{snap['name']}\" is no longer available" unless option
            option
          end
        end
      end
    end
  end
end
