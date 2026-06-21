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
    end

    module Mutations
      include Types::Interfaces::BaseInterface
      description "Order mutations"
      graphql_name "OrderMutations"

      field :complete_order, mutation: ::Mutations::Orders::CompleteOrder,
        description: "Mark an order ready with a photo"
      field :create_order, mutation: ::Mutations::Orders::CreateOrder,
        description: "Place a guest order"
      field :reorder, mutation: ::Mutations::Orders::Reorder,
        description: "Reorder a past order into the open session"
      field :update_order_status, mutation: ::Mutations::Orders::UpdateOrderStatus,
        description: "Advance an order's status"
    end
  end
end
