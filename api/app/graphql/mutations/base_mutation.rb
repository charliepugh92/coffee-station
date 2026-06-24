# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::Arguments::BaseArgument
    field_class Types::Fields::BaseField
    input_object_class Types::InputObjects::BaseInputObject
    object_class Types::Objects::BaseObject

    private

    def current_user
      context[:current_user]
    end

    def require_auth!
      raise GraphQL::ExecutionError, "Authentication required" unless current_user
    end

    # Ownership-scoped finders — every host mutation acts only on records that
    # belong to the authenticated user's stations.
    def find_owned_station!(id)
      require_auth!
      current_user.stations.find_by(id:) || not_found!("Station")
    end

    def find_owned_category!(id)
      require_auth!
      CustomizationCategory.where(station: current_user.stations).find_by(id:) || not_found!("Category")
    end

    def find_owned_option!(id)
      require_auth!
      CustomizationOption
        .joins(customization_category: :station)
        .where(stations: { user_id: current_user.id })
        .find_by(id:) || not_found!("Option")
    end

    def find_owned_preset!(id)
      require_auth!
      MenuPreset.where(station: current_user.stations).find_by(id:) || not_found!("Preset")
    end

    def find_owned_base!(id)
      require_auth!
      ::Base.where(station: current_user.stations).find_by(id:) || not_found!("Base")
    end

    def find_owned_session!(id)
      require_auth!
      Session.where(station: current_user.stations).find_by(id:) || not_found!("Session")
    end

    def find_owned_order!(id)
      require_auth!
      Order.joins(session: :station)
           .where(stations: { user_id: current_user.id })
           .find_by(id:) || not_found!("Order")
    end

    def not_found!(label)
      raise GraphQL::ExecutionError, "#{label} not found"
    end

    # --- Realtime triggers (GraphQL subscriptions over ActionCable) ---

    def trigger_order_added(order)
      ApiSchema.subscriptions.trigger(:order_added, { session_token: order.session.share_token }, order)
      push_host_new_order(order)
    end

    def trigger_order_updated(order)
      broadcast_order_updated(order)
      # Only the genuine "ready" hand-off pushes the guest. trigger_order_updated
      # also fires for other status changes and from trigger_queue_refresh, which
      # would otherwise spam every queued guest on each status bump.
      push_guest_order_ready(order) if order.ready?
    end

    # Broadcast the order's current state to its guest subscription over
    # ActionCable WITHOUT sending a Web Push. Used for follow-up updates (e.g. the
    # completion photo landing after the ready push has already fired) so the live
    # page refreshes without double-notifying the guest.
    def broadcast_order_updated(order)
      ApiSchema.subscriptions.trigger(:order_updated, { order_token: order.guest_token }, order)
    end

    def trigger_session_updated(session)
      ApiSchema.subscriptions.trigger(:session_updated, { session_token: session.share_token }, session)
    end

    # Re-notify every still-queued order in the session so each guest's
    # queuePosition re-renders after one ahead of them is finished/advanced.
    def trigger_queue_refresh(session)
      session.orders.where(status: Order::ACTIVE_STATUSES).find_each { |order| trigger_order_updated(order) }
    end

    # --- Web Push (background notifications, even when the tab is closed) ---

    def push_host_new_order(order)
      station = order.session.station
      payload = {
        title: "New order — #{order.guest_name}",
        body: order_summary(order),
        url: "/stations/#{station.id}/board",
        tag: "order-#{order.id}"
      }
      deliver_push(station.user.push_devices, payload, context: "host new order #{order.id}")
    end

    def push_guest_order_ready(order)
      payload = {
        title: "Your drink is ready! ☕",
        body: "#{order.guest_name}, pick up your order at #{order.station.name}.",
        url: "/o/#{order.guest_token}",
        tag: "order-#{order.id}-ready"
      }
      deliver_push(order.push_devices, payload, context: "order #{order.id} ready")
    end

    # Send a payload to every device, one per endpoint. Per-endpoint failures are
    # swallowed inside WebPushSender so one dead device can't block the rest or
    # raise out of the request. We log the device count so production can confirm
    # whether a "missing notification" was a no-op send (zero devices) vs a
    # delivery failure.
    def deliver_push(devices, payload, context:)
      devices = devices.distinct
      Rails.logger.info("[push] #{context}: notifying #{devices.count} device(s)")
      devices.find_each { |device| WebPushSender.deliver(device, payload) }
    end

    def order_summary(order)
      [ order.menu_preset&.name, order.base&.name ].compact.join(" · ").presence || order.guest_name
    end
  end
end
