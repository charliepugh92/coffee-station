# Bearer-token authentication for non-Devise endpoints (GraphQL). Decodes through
# warden-jwt_auth so the secret/algorithm/expiry always match what devise-jwt
# encoded, and honors revocation by looking the token's jti up in the per-device
# allowlist (user_sessions) rather than a single jti on the user.
module JwtAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user_from_token!
  end

  private

  def authenticate_user_from_token!
    header = request.headers["Authorization"]
    return unless header&.start_with?("Bearer ")

    token = header.split(" ").last
    payload = Warden::JWTAuth::TokenDecoder.new.call(token)
    session = UserSession.active.find_by(jti: payload["jti"], user_id: payload["sub"])
    return unless session

    session.touch_activity!(request.user_agent)
    @current_user = session.user
    @current_jti = session.jti
  rescue JWT::DecodeError
    nil
  end

  def current_user
    @current_user
  end

  # The jti of the token on this request — lets GraphQL flag the caller's own
  # session as "this device".
  def current_jti
    @current_jti
  end
end
