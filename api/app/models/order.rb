class Order < ApplicationRecord
  belongs_to :session
  belongs_to :base, optional: true
  belongs_to :menu_preset, optional: true
  has_one_attached :completion_photo
  has_one :rating, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :push_subscriptions, as: :subscriber, dependent: :destroy
  has_many :push_devices, through: :push_subscriptions

  has_secure_token :guest_token

  enum :status, { pending: 0, in_progress: 1, ready: 2 }

  delegate :station, to: :session

  validates :guest_name, presence: true, length: { maximum: 60 }

  # Snapshot of an order's contents, stored on `memory` so display and reorder
  # never depend on live menu records (the host may delete/edit them freely).
  # Shape: { "base" => {id,name}|nil, "preset" => {id,name}|nil,
  #          "groups" => [{ "categoryId", "category", "options" => [{id,name}] }] }
  def self.build_memory(base:, preset:, options:)
    groups = options
      .group_by(&:customization_category)
      .sort_by { |category, _| category.position }
      .map do |category, opts|
        {
          "categoryId" => category.id,
          "category" => category.name,
          "options" => opts.sort_by(&:position).map { |o| { "id" => o.id, "name" => o.name } }
        }
      end
    {
      "base" => base && { "id" => base.id, "name" => base.name },
      "preset" => preset && { "id" => preset.id, "name" => preset.name },
      "groups" => groups
    }
  end

  # Orders still in the make-line (not yet handed off).
  ACTIVE_STATUSES = %w[pending in_progress].freeze

  # 1-based position among the session's un-finished orders (oldest first), or
  # nil once the order is ready.
  def queue_position
    return nil unless ACTIVE_STATUSES.include?(status)

    session.orders
           .where(status: ACTIVE_STATUSES)
           .where(created_at: ...created_at)
           .count + 1
  end
end
