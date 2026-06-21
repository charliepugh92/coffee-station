class Session < ApplicationRecord
  belongs_to :station

  has_secure_token :share_token

  enum :status, { open: 0, closed: 1 }

  delegate :user_id, to: :station, prefix: true

  def accepting_orders?
    open?
  end

  def close!
    update!(status: :closed, closed_at: Time.current)
  end
end
