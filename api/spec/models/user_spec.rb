require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  it "has a valid factory" do
    expect(user).to be_valid
  end

  it { is_expected.to validate_presence_of(:display_name) }
  it { is_expected.to validate_length_of(:display_name).is_at_most(50) }

  it "generates a decodable JWT for the user" do
    user.save!
    token = user.generate_jwt
    payload = Warden::JWTAuth::TokenDecoder.new.call(token)
    expect(payload["sub"]).to eq(user.id.to_s)
  end

  it "registers an active device session when minting a JWT" do
    user.save!
    expect { user.generate_jwt }.to change { user.user_sessions.count }.by(1)
  end

  it "mints independent sessions per device (multi-device)" do
    user.save!
    user.generate_jwt
    user.generate_jwt
    expect(user.user_sessions.count).to eq(2)
  end
end
