# frozen_string_literal: true

module Types
  module InputObjects
    class CategoryAttrsInput < BaseInputObject
      description "Attributes for creating or updating a customization category"

      argument :name, String, required: true, description: "Category name"
      argument :position, Integer, required: false, description: "Display order within the station"
      argument :required, Boolean, required: false, description: "Whether an order must choose from this category"
      argument :selection_mode, Types::Enums::SelectionModeEnum, required: false, description: "Single choice or multiple"
    end
  end
end
