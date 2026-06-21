# frozen_string_literal: true

module Types
  module Objects
    class CommentType < BaseObject
      description "A guest's comment about their order"

      field :body, String, null: false, description: "The comment text"
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false, description: "When the comment was left"
      field :id, ID, null: false, description: "Unique comment ID"
    end
  end
end
