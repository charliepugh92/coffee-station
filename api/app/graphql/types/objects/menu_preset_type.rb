# frozen_string_literal: true

module Types
  module Objects
    class MenuPresetType < BaseObject
      description "A curated combination of options (e.g. \"Caramel Macchiato\")"

      field :description, String, null: true, description: "Optional preset description"
      field :id, ID, null: false, description: "Unique preset ID"
      field :image_url, String, null: true, description: "Optional photo of the finished drink"
      field :name, String, null: false, description: "Preset name"
      field :options, [ CustomizationOptionType ], null: false, description: "The options this preset bundles", method: :customization_options
      field :position, Integer, null: false, description: "Display order within the station"

      def image_url
        attachment_url(object.image)
      end
    end
  end
end
