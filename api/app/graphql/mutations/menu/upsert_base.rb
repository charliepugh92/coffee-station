# frozen_string_literal: true

module Mutations
  module Menu
    class UpsertBase < Mutations::BaseMutation
      description "Create or update a base drink and the categories it enables"

      argument :attrs, Types::InputObjects::BaseAttrsInput, required: true, description: "Base attributes"
      argument :category_ids, [ ID ], required: false, description: "Categories this base enables (replaces the current set)"
      argument :id, ID, required: false, description: "Omit to create; provide to update"
      argument :station_id, ID, required: true, description: "Owning station ID"

      field :base, Types::Objects::BaseType, null: true, description: "The resulting base"
      field :errors, [ String ], null: false, description: "Validation errors, if any"

      def resolve(station_id:, attrs:, id: nil, category_ids: nil)
        station = find_owned_station!(station_id)
        base = id ? find_owned_base!(id) : station.bases.build
        base.assign_attributes(attrs.to_h)
        return { base: nil, errors: base.errors.full_messages } unless base.save

        base.customization_category_ids = sanitize_category_ids(station, category_ids) unless category_ids.nil?
        { base:, errors: [] }
      end

      private

      # Only categories that actually belong to this station may be enabled.
      def sanitize_category_ids(station, category_ids)
        category_ids.map(&:to_i) & station.customization_categories.ids
      end
    end
  end
end
