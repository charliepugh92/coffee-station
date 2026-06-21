class Order < ApplicationRecord
  belongs_to :session
  belongs_to :base_option, class_name: "CustomizationOption", optional: true
  belongs_to :menu_preset, optional: true
  has_one_attached :completion_photo
  has_many :order_selections, dependent: :destroy
  has_many :customization_options, through: :order_selections

  has_secure_token :guest_token

  enum :status, { pending: 0, in_progress: 1, ready: 2, picked_up: 3 }

  delegate :station, to: :session

  validates :guest_name, presence: true, length: { maximum: 60 }

  # Orders still in the make-line (not yet handed off).
  ACTIVE_STATUSES = %w[pending in_progress].freeze

  # 1-based position among the session's un-finished orders (oldest first), or
  # nil once the order is ready/picked up.
  def queue_position
    return nil unless ACTIVE_STATUSES.include?(status)

    session.orders
           .where(status: ACTIVE_STATUSES)
           .where(created_at: ...created_at)
           .count + 1
  end
end
