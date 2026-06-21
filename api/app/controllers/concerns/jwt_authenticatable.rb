# Bearer-token authentication for non-Devise endpoints (GraphQL). Decodes through
# warden-jwt_auth so the secret/algorithm/expiry always match what devise-jwt
# encoded, and honors jti revocation by matching the User's current jti.
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
    @current_user = User.find_by(id: payload["sub"], jti: payload["jti"])
  rescue JWT::DecodeError
    nil
  end

  def current_user
    @current_user
  end
end
