# frozen_string_literal: true

module Types
  module InputObjects
    class PresetAttrsInput < BaseInputObject
      description "Attributes for creating or updating a menu preset"

      argument :description, String, required: false, description: "Optional preset description"
      argument :name, String, required: true, description: "Preset name"
      argument :position, Integer, required: false, description: "Display order within the station"
    end
  end
end
