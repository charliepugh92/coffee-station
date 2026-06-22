# frozen_string_literal: true

# One row per dispatched JWT — a single host "device" sign-in. Backs the
# allowlist-based JWT revocation (see UserSessionRevocationStrategy).
class UserSession < ApplicationRecord
  belongs_to :user

  validates :jti, presence: true, uniqueness: true
  validates :exp, presence: true

  scope :active, -> { where("exp > ?", Time.current) }

  # Called on each authenticated request. Bumps activity and, on first sight,
  # backfills a human-friendly device label from the request's User-Agent (the
  # dispatch hook has no request context, so we capture it here).
  def touch_activity!(user_agent_string)
    attrs = { last_active_at: Time.current }
    if self.user_agent.blank? && user_agent_string.present?
      attrs[:user_agent] = user_agent_string
      attrs[:device_label] = self.class.device_label_for(user_agent_string)
    end
    update_columns(attrs)
  end

  # Best-effort "Browser on OS" label from a User-Agent string — no gem, just a few
  # heuristics covering the common cases. Falls back to "Unknown device".
  def self.device_label_for(ua)
    return "Unknown device" if ua.blank?

    browser =
      case ua
      when /Edg/i                       then "Edge"
      when /OPR|Opera/i                 then "Opera"
      when /Firefox|FxiOS/i             then "Firefox"
      when /Chrome|CriOS/i              then "Chrome"
      when /Safari/i                    then "Safari"
      end

    os =
      case ua
      when /iPhone/i                    then "iPhone"
      when /iPad/i                      then "iPad"
      when /Android/i                   then "Android"
      when /Mac OS X|Macintosh/i        then "macOS"
      when /Windows/i                   then "Windows"
      when /Linux/i                     then "Linux"
      end

    # "Chrome on macOS", or just one part, or the fallback.
    [ browser, os ].compact.join(" on ").presence || "Unknown device"
  end
end
