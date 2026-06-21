# frozen_string_literal: true

module Types
  module InputObjects
    class StationAttrsInput < BaseInputObject
      description "Attributes for creating or updating a station"

      argument :description, String, required: false, description: "Optional blurb shown to guests"
      argument :name, String, required: true, description: "Station name"
      argument :slug, String, required: false, description: "Optional human-friendly identifier (lowercase, hyphens)"
    end
  end
end
