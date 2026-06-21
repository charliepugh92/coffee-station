class MenuPreset < ApplicationRecord
  belongs_to :station
  has_one_attached :image
  has_many :menu_preset_options, dependent: :destroy
  has_many :customization_options, through: :menu_preset_options

  validates :name, presence: true, length: { maximum: 80 }
end
