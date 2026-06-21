# frozen_string_literal: true

module Mutations
  module Menu
    class UpsertOption < Mutations::BaseMutation
      description "Create or update a customization option within a category"

      argument :attrs, Types::InputObjects::OptionAttrsInput, required: true, description: "Option attributes"
      argument :category_id, ID, required: true, description: "Owning category ID"
      argument :id, ID, required: false, description: "Omit to create; provide to update"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :option, Types::Objects::CustomizationOptionType, null: true, description: "The resulting option"

      def resolve(category_id:, attrs:, id: nil)
        category = find_owned_category!(category_id)
        option = id ? find_owned_option!(id) : category.customization_options.build
        option.assign_attributes(attrs.to_h)
        if option.save
          { option:, errors: [] }
        else
          { option: nil, errors: option.errors.full_messages }
        end
      end
    end
  end
end
