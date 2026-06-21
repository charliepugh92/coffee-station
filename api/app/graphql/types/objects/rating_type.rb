# frozen_string_literal: true

module Types
  module Objects
    class RatingType < BaseObject
      description "A guest's 1–5 star rating of their order"

      field :created_at, GraphQL::Types::ISO8601DateTime, null: false, description: "When the rating was left"
      field :id, ID, null: false, description: "Unique rating ID"
      field :stars, Integer, null: false, description: "Star rating, 1 to 5"
    end
  end
end
