# frozen_string_literal: true

module Mutations
  module Menu
    class UpsertCategory < Mutations::BaseMutation
      description "Create or update a customization category on a station's menu"

      argument :attrs, Types::InputObjects::CategoryAttrsInput, required: true, description: "Category attributes"
      argument :id, ID, required: false, description: "Omit to create; provide to update"
      argument :station_id, ID, required: true, description: "Owning station ID"

      field :category, Types::Objects::CustomizationCategoryType, null: true, description: "The resulting category"
      field :errors, [ String ], null: false, description: "Validation errors, if any"

      def resolve(station_id:, attrs:, id: nil)
        station = find_owned_station!(station_id)
        category = id ? find_owned_category!(id) : station.customization_categories.build
        category.assign_attributes(attrs.to_h)
        if category.save
          { category:, errors: [] }
        else
          { category: nil, errors: category.errors.full_messages }
        end
      end
    end
  end
end
