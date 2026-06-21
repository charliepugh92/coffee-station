# frozen_string_literal: true

module Mutations
  module Menu
    class ReorderCategories < Mutations::BaseMutation
      description "Set the display order of a station's customization categories"

      argument :ordered_ids, [ ID ], required: true, description: "Category IDs in the desired order"
      argument :station_id, ID, required: true, description: "Owning station ID"

      field :categories, [ Types::Objects::CustomizationCategoryType ], null: false, description: "Categories in their new order"
      field :errors, [ String ], null: false, description: "Validation errors, if any"

      def resolve(station_id:, ordered_ids:)
        station = find_owned_station!(station_id)
        ordered_ids.each_with_index do |cid, index|
          station.customization_categories.where(id: cid).update_all(position: index)
        end
        { categories: station.customization_categories.reload, errors: [] }
      end
    end
  end
end
