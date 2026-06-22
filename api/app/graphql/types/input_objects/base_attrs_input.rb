# frozen_string_literal: true

module Types
  module InputObjects
    class BaseAttrsInput < BaseInputObject
      description "Attributes for creating or updating a base drink"

      argument :description, String, required: false, description: "Optional description"
      argument :name, String, required: true, description: "Base name"
      argument :position, Integer, required: false, description: "Display order within the station"
      argument :surcharge_cents, Integer, required: false, description: "Optional upcharge in cents"
    end
  end
end
