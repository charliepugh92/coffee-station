# frozen_string_literal: true

module Types
  module Objects
    class CustomizationOptionType < BaseObject
      description "A single selectable customization (e.g. Oat milk, Vanilla syrup)"

      field :id, ID, null: false, description: "Unique option ID"
      field :image_url, String, null: true, description: "Optional photo of this option"
      field :name, String, null: false, description: "Option name"
      field :position, Integer, null: false, description: "Display order within the category"
      field :surcharge_cents, Integer, null: true, description: "Optional upcharge in cents"

      def image_url
        attachment_url(object.image)
      end
    end
  end
end
