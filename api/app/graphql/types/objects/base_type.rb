# frozen_string_literal: true

module Types
  module Objects
    class BaseType < BaseObject
      description "A base drink (e.g. Latte, Cappuccino, Espresso) that enables a set of customization categories"

      field :categories, [ CustomizationCategoryType ], null: false,
        description: "Categories this base makes available", method: :customization_categories
      field :description, String, null: true, description: "Optional description"
      field :id, ID, null: false, description: "Unique base ID"
      field :image_url, String, null: true, description: "Optional photo of the base drink"
      field :name, String, null: false, description: "Base name"
      field :position, Integer, null: false, description: "Display order within the station"
      field :surcharge_cents, Integer, null: true, description: "Optional upcharge for choosing this base"

      def image_url
        attachment_url(object.image)
      end
    end
  end
end
