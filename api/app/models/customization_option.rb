class CustomizationOption < ApplicationRecord
  belongs_to :customization_category
  has_one_attached :image
  has_many :menu_preset_options
  has_many :menu_presets, through: :menu_preset_options

  # A preset is a specific flavor combo; if one of its options goes away the combo
  # no longer makes sense, so the whole preset is removed (also fires when a
  # category cascade deletes the option). Declared before any dependent-destroy of
  # the join rows so the presets are still reachable; destroying each preset
  # cascades to clean up its menu_preset_options. NB: `menu_presets.destroy_all`
  # on a has_many :through would only delete the join rows, so destroy the records.
  before_destroy { menu_presets.to_a.each(&:destroy) }

  delegate :station, to: :customization_category

  validates :name, presence: true, length: { maximum: 60 }
  validates :surcharge_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
