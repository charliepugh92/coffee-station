# frozen_string_literal: true

module Types
  module Objects
    class CustomizationCategoryType < BaseObject
      description "A group of customizations (e.g. Base, Milk, Syrup) on a station's menu"

      field :id, ID, null: false, description: "Unique category ID"
      field :name, String, null: false, description: "Category name"
      field :options, [ CustomizationOptionType ], null: false, description: "Selectable options, ordered", method: :customization_options
      field :position, Integer, null: false, description: "Display order within the station"
      field :required, Boolean, null: false, description: "Whether an order must choose from this category"
      field :selection_mode, Types::Enums::SelectionModeEnum, null: false, description: "Single choice or multiple"
    end
  end
end
