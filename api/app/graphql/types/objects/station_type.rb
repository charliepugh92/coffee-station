# frozen_string_literal: true

module Types
  module Objects
    class StationType < BaseObject
      description "A coffee station owned by a host — holds a durable, reusable menu"

      field :bases, [ BaseType ], null: false, description: "Base drinks, ordered"
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false, description: "When the station was created"
      field :customization_categories, [ CustomizationCategoryType ], null: false, description: "Menu categories, ordered"
      field :description, String, null: true, description: "Optional blurb shown to guests"
      field :id, ID, null: false, description: "Unique station ID"
      field :menu_presets, [ MenuPresetType ], null: false, description: "Curated combinations, ordered"
      field :name, String, null: false, description: "Station name"
      field :open_session, "Types::Objects::SessionType", null: true,
        description: "The currently open session, if the station is open"
      field :slug, String, null: true, description: "Optional human-friendly identifier, unique per host"
    end
  end
end
