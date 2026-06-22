# frozen_string_literal: true

module Types
  module Objects
    class OrderMemoryType < BaseObject
      description "A self-contained snapshot of an order's contents, independent of the live menu"

      field :base_name, String, null: true, description: "Chosen base name as it was when ordered"
      field :groups, [ OrderMemoryGroupType ], null: false, description: "Chosen options grouped by category"
      field :preset_name, String, null: true, description: "Chosen preset name as it was when ordered"

      def base_name
        object["base"]&.fetch("name", nil)
      end

      def preset_name
        object["preset"]&.fetch("name", nil)
      end

      def groups
        Array(object["groups"])
      end
    end
  end
end
