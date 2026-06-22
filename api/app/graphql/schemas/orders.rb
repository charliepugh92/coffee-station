# frozen_string_literal: true

module Schemas
  module Orders
    module Queries
      include Types::Interfaces::BaseInterface
      description "Public order lookup for guests"
      graphql_name "OrderQueries"

      field :order_by_token, Types::Objects::OrderType, null: true,
        description: "Look up an order by its guest token (the capability the guest holds)" do
        argument :token, String, required: true, description: "The order's guest token"
      end
      field :order_history, [ Types::Objects::OrderType ], null: false,
        description: "The current host's past orders across their stations, most recent first" do
        argument :limit, Integer, required: false, description: "Max orders to return (default 50, max 100)"
        argument :offset, Integer, required: false, description: "Offset for pagination"
        argument :station_id, ID, required: false, description: "Filter to a single station"
      end
      field :orders_by_tokens, [ Types::Objects::OrderType ], null: false,
        description: "A returning customer's order history — resolves only the orders whose token is supplied" do
        argument :tokens, [ String ], required: true, description: "Guest tokens from the browser's persisted list"
      end

      def order_by_token(token:)
        Order.find_by(guest_token: token)
      end

      def orders_by_tokens(tokens:)
        Order.where(guest_token: tokens).order(created_at: :desc)
      end

      def order_history(station_id: nil, limit: 50, offset: 0)
        user = context[:current_user]
        return [] unless user

        scope = Order.joins(session: :station).where(stations: { user_id: user.id })
        scope = scope.where(stations: { id: station_id }) if station_id
        scope.order(created_at: :desc).limit(limit.to_i.clamp(1, 100)).offset([ offset.to_i, 0 ].max)
      end
    end

    module Mutations
      include Types::Interfaces::BaseInterface
      description "Order mutations"
      graphql_name "OrderMutations"

      field :complete_order, mutation: ::Mutations::Orders::CompleteOrder,
        description: "Mark an order ready with a photo"
      field :create_order, mutation: ::Mutations::Orders::CreateOrder,
        description: "Place a guest order"
      field :delete_order, mutation: ::Mutations::Orders::DeleteOrder,
        description: "Delete an order and its photo (host only)"
      field :reorder, mutation: ::Mutations::Orders::Reorder,
        description: "Reorder a past order into the open session"
      field :update_order_status, mutation: ::Mutations::Orders::UpdateOrderStatus,
        description: "Advance an order's status"
    end
  end
end
