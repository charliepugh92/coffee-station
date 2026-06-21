# frozen_string_literal: true

module Types
  module InputObjects
    class OptionAttrsInput < BaseInputObject
      description "Attributes for creating or updating a customization option"

      argument :name, String, required: true, description: "Option name"
      argument :position, Integer, required: false, description: "Display order within the category"
      argument :surcharge_cents, Integer, required: false, description: "Optional upcharge in cents"
    end
  end
end
