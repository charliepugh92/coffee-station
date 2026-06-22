# frozen_string_literal: true

# A devise-jwt revocation strategy backed by a per-device allowlist (the
# `user_sessions` table) instead of a single `jti` column on the user.
#
# Each dispatched token carries a fresh `jti` (see #jwt_payload), and #on_jwt_dispatch
# records one `UserSession` row per dispatch. A token is valid only while its row
# exists, so revoking one device (logout) leaves every other device signed in.
#
# Shaped after Devise::JWT::RevocationStrategies::JTIMatcher. The dispatch hook is
# invoked by warden-jwt_auth (Warden::JWTAuth::Hooks#add_token_to_env) when the
# resource responds to #on_jwt_dispatch.
module UserSessionRevocationStrategy
  extend ActiveSupport::Concern

  class_methods do
    # @see Warden::JWTAuth::Interfaces::RevocationStrategy#jwt_revoked?
    def jwt_revoked?(payload, user)
      !user.user_sessions.exists?(jti: payload["jti"])
    end

    # @see Warden::JWTAuth::Interfaces::RevocationStrategy#revoke_jwt
    def revoke_jwt(payload, user)
      user.user_sessions.where(jti: payload["jti"]).delete_all
    end
  end

  # @see Warden::JWTAuth::Interfaces::User#jwt_payload — a new jti per dispatch is
  # what makes each login an independent device session.
  def jwt_payload
    { "jti" => SecureRandom.uuid }
  end

  # @see Warden::JWTAuth::Interfaces::User#on_jwt_dispatch
  def on_jwt_dispatch(_token, payload)
    user_sessions.where(exp: ..Time.current).delete_all # opportunistic prune of expired rows
    user_sessions.create!(jti: payload["jti"], exp: Time.at(payload["exp"]).utc)
  end
end
