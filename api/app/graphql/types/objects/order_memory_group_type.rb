# frozen_string_literal: true

module Types
  module Objects
    class OrderMemoryGroupType < BaseObject
      description "One category's chosen options within an order's snapshot"

      field :category, String, null: false, hash_key: "category",
        description: "Category name as it was when ordered"
      field :options, [ String ], null: false, description: "Chosen option names"

      def options
        Array(object["options"]).map { |o| o["name"] }
      end
    end
  end
end
