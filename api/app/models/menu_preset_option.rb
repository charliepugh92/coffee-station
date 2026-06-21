class MenuPresetOption < ApplicationRecord
  belongs_to :menu_preset
  belongs_to :customization_option

  validates :customization_option_id, uniqueness: { scope: :menu_preset_id }
end
