# frozen_string_literal: true

module Types
  module Enums
    class SelectionModeEnum < BaseEnum
      description "How many options a customization category allows: a single choice or many"
      generate_from_rails_enum CustomizationCategory.selection_modes
    end
  end
end
