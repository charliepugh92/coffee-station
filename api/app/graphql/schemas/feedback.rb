# frozen_string_literal: true

module Schemas
  module Feedback
    module Mutations
      include Types::Interfaces::BaseInterface
      description "Guest feedback mutations (ratings and comments)"
      graphql_name "FeedbackMutations"

      field :add_comment, mutation: ::Mutations::Feedback::AddComment,
        description: "Leave a comment on an order"
      field :rate_order, mutation: ::Mutations::Feedback::RateOrder,
        description: "Rate an order 1–5 stars"
    end
  end
end
