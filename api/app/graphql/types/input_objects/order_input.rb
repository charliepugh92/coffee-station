# frozen_string_literal: true

module Types
  module InputObjects
    class OrderInput < BaseInputObject
      description "The contents of a guest's order"

      argument :base_id, ID, required: false, description: "Chosen base drink"
      argument :guest_name, String, required: true, description: "Name to call out when ready"
      argument :menu_preset_id, ID, required: false, description: "A curated preset, if picked"
      argument :notes, String, required: false, description: "Free-text notes for the barista"
      argument :option_ids, [ ID ], required: false, description: "Chosen customization options"
    end
  end
end
