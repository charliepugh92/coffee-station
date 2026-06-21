# frozen_string_literal: true

module Schemas
  module Menu
    module Mutations
      include Types::Interfaces::BaseInterface
      description "Menu-building mutations (categories, options, presets)"
      graphql_name "MenuMutations"

      field :delete_category, mutation: ::Mutations::Menu::DeleteCategory,
        description: "Delete a customization category"
      field :delete_option, mutation: ::Mutations::Menu::DeleteOption,
        description: "Delete a customization option"
      field :delete_preset, mutation: ::Mutations::Menu::DeletePreset,
        description: "Delete a menu preset"
      field :reorder_categories, mutation: ::Mutations::Menu::ReorderCategories,
        description: "Reorder a station's categories"
      field :upload_option_image, mutation: ::Mutations::Menu::UploadOptionImage,
        description: "Attach an image to an option"
      field :upload_preset_image, mutation: ::Mutations::Menu::UploadPresetImage,
        description: "Attach an image to a preset"
      field :upsert_category, mutation: ::Mutations::Menu::UpsertCategory,
        description: "Create or update a category"
      field :upsert_option, mutation: ::Mutations::Menu::UpsertOption,
        description: "Create or update an option"
      field :upsert_preset, mutation: ::Mutations::Menu::UpsertPreset,
        description: "Create or update a preset"
    end
  end
end
