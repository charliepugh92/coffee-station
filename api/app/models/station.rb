class Station < ApplicationRecord
  belongs_to :user
  has_many :customization_categories, -> { order(:position) }, dependent: :destroy
  has_many :menu_presets, -> { order(:position) }, dependent: :destroy

  validates :name, presence: true, length: { maximum: 80 }
  validates :slug, uniqueness: { scope: :user_id }, allow_nil: true,
    format: { with: /\A[a-z0-9\-]+\z/ }, length: { maximum: 50 }, if: -> { slug.present? }
end
