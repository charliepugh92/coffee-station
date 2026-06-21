class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Email/password only — no :omniauthable, :confirmable, etc.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :stations, dependent: :destroy

  validates :display_name, presence: true, length: { maximum: 50 }

  # Mint a JWT for this user (used by the OAuth-free login/registration responses).
  def generate_jwt
    Warden::JWTAuth::UserEncoder.new.call(self, :user, nil).first
  end
end
