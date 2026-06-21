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

      def order_by_token(token:)
        Order.find_by(guest_token: token)
      end
    end

    module Mutations
      include Types::Interfaces::BaseInterface
      description "Order mutations"
      graphql_name "OrderMutations"

      field :create_order, mutation: ::Mutations::Orders::CreateOrder,
        description: "Place a guest order"
      field :update_order_status, mutation: ::Mutations::Orders::UpdateOrderStatus,
        description: "Advance an order's status"
    end
  end
end
