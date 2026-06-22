# frozen_string_literal: true

# Sends a single Web Push message to one subscription, signed with our VAPID keys.
# Dead endpoints (the push service replies 404/410) are pruned on the spot — this
# is the primary garbage-collection path for stale subscriptions.
class WebPushSender
  def self.deliver(subscription, payload)
    creds = Rails.application.credentials.web_push
    return Rails.logger.warn("WebPush: VAPID keys not configured; skipping") unless creds&.dig(:vapid_public_key)

    WebPush.payload_send(
      endpoint: subscription.endpoint,
      p256dh: subscription.p256dh_key,
      auth: subscription.auth_key,
      message: payload.to_json,
      vapid: {
        public_key: creds[:vapid_public_key],
        private_key: creds[:vapid_private_key],
        subject: creds[:vapid_subject]
      }
    )
  rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription
    subscription.destroy
  rescue WebPush::ResponseError => e
    Rails.logger.warn("WebPush delivery failed: #{e.message}")
  end
end
