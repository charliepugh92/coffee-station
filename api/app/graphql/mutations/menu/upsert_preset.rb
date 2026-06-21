# frozen_string_literal: true

module Mutations
  module Menu
    class UpsertPreset < Mutations::BaseMutation
      description "Create or update a curated preset and the options it bundles"

      argument :attrs, Types::InputObjects::PresetAttrsInput, required: true, description: "Preset attributes"
      argument :id, ID, required: false, description: "Omit to create; provide to update"
      argument :option_ids, [ ID ], required: false, description: "Options to bundle (replaces the current set)"
      argument :station_id, ID, required: true, description: "Owning station ID"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :preset, Types::Objects::MenuPresetType, null: true, description: "The resulting preset"

      def resolve(station_id:, attrs:, id: nil, option_ids: nil)
        station = find_owned_station!(station_id)
        preset = id ? find_owned_preset!(id) : station.menu_presets.build
        preset.assign_attributes(attrs.to_h)
        return { preset: nil, errors: preset.errors.full_messages } unless preset.save

        preset.customization_option_ids = sanitize_option_ids(station, option_ids) unless option_ids.nil?
        { preset:, errors: [] }
      end

      private

      # Only options that actually belong to this station may be bundled.
      def sanitize_option_ids(station, option_ids)
        station_option_ids = CustomizationOption
          .where(customization_category_id: station.customization_categories.select(:id)).ids
        option_ids.map(&:to_i) & station_option_ids
      end
    end
  end
end
