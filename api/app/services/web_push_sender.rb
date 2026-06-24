# frozen_string_literal: true

# Sends a single Web Push message to one device, signed with our VAPID keys.
# Every failure is contained here: this runs inline inside a request, so an
# unrescued error would 500 the mutation and abort delivery to the remaining
# devices. Dead endpoints (404/410) are pruned on the spot — the primary
# garbage-collection path for stale registrations.
class WebPushSender
  # Bound the outbound call so a slow/unreachable push service can't stall the
  # request thread.
  TIMEOUTS = { open_timeout: 5, read_timeout: 5 }.freeze

  def self.deliver(device, payload)
    creds = Rails.application.credentials.web_push
    return Rails.logger.warn("WebPush: VAPID keys not configured; skipping") unless creds&.dig(:vapid_public_key)

    WebPush.payload_send(
      endpoint: device.endpoint,
      p256dh: device.p256dh_key,
      auth: device.auth_key,
      message: payload.to_json,
      vapid: {
        public_key: creds[:vapid_public_key],
        private_key: creds[:vapid_private_key],
        subject: creds[:vapid_subject]
      },
      **TIMEOUTS
    )
  rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription
    device.destroy
  rescue WebPush::Unauthorized => e
    # Almost always a VAPID key mismatch (e.g. prod vs dev keys). Previously
    # swallowed as a generic warning, which silently broke ALL delivery — log it
    # loudly as an error so it surfaces.
    Rails.logger.error("WebPush VAPID unauthorized (check VAPID keys): #{e.message}")
  rescue WebPush::ResponseError => e
    # PayloadTooLarge, PushServiceError (5xx), and other endpoint-specific errors.
    Rails.logger.warn("WebPush delivery failed for device #{device.id}: #{e.message}")
  rescue Net::OpenTimeout, Net::ReadTimeout, IOError, SocketError, OpenSSL::SSL::SSLError, SystemCallError => e
    # Network-level failures aren't WebPush::Error subclasses, so without this
    # they'd propagate out and 500 the completeOrder mutation.
    Rails.logger.warn("WebPush network error for device #{device.id} (#{e.class}): #{e.message}")
  end
end
