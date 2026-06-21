require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  it "has a valid factory" do
    expect(user).to be_valid
  end

  it { is_expected.to validate_presence_of(:display_name) }
  it { is_expected.to validate_length_of(:display_name).is_at_most(50) }

  it "assigns a jti on create (for JWT revocation)" do
    user.save!
    expect(user.jti).to be_present
  end

  it "generates a decodable JWT for the user" do
    user.save!
    token = user.generate_jwt
    payload = Warden::JWTAuth::TokenDecoder.new.call(token)
    expect(payload["sub"]).to eq(user.id.to_s)
  end
end
