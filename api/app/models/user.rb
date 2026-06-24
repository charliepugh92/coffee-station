class User < ApplicationRecord
  # Per-device JWT allowlist — lets the host stay signed in on multiple devices
  # and revoke them independently (see UserSessionRevocationStrategy).
  include UserSessionRevocationStrategy

  # Email/password only — no :omniauthable, :confirmable, etc.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :stations, dependent: :destroy
  has_many :push_subscriptions, as: :subscriber, dependent: :destroy
  has_many :push_devices, through: :push_subscriptions
  has_many :user_sessions, dependent: :destroy

  validates :display_name, presence: true, length: { maximum: 50 }

  # Mint a JWT for this user and register it as an active device session, so the
  # token authenticates against the allowlist just like a real login would.
  def generate_jwt
    token, payload = Warden::JWTAuth::UserEncoder.new.call(self, :user, nil)
    on_jwt_dispatch(token, payload)
    token
  end
end
