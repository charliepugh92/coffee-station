class CustomizationOption < ApplicationRecord
  belongs_to :customization_category
  has_one_attached :image
  has_many :menu_preset_options, dependent: :destroy

  delegate :station, to: :customization_category

  validates :name, presence: true, length: { maximum: 60 }
  validates :surcharge_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
