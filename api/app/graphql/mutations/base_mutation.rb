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
    end

    def trigger_order_updated(order)
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
  end
end
