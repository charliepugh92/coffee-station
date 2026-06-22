require "rails_helper"

RSpec.describe "Auth", type: :request do
  describe "POST /users (sign up)" do
    it "creates a user and returns a JWT", :aggregate_failures do
      post "/users", params: { user: { email: "new@example.com", password: "beanjuice123", display_name: "New Host" } }, as: :json
      expect(response).to have_http_status(:created)
      expect(response.headers["Authorization"]).to start_with("Bearer ")
      expect(response.parsed_body.dig("data", "user", "display_name")).to eq("New Host")
    end

    it "returns validation errors for a bad signup", :aggregate_failures do
      post "/users", params: { user: { email: "", password: "x", display_name: "" } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_present
    end
  end

  describe "POST /users/sign_in (login)" do
    before { create(:user, email: "host@example.com", password: "beanjuice123") }

    it "returns a JWT for valid credentials", :aggregate_failures do
      post "/users/sign_in", params: { user: { email: "host@example.com", password: "beanjuice123" } }, as: :json
      expect(response).to have_http_status(:ok)
      expect(response.headers["Authorization"]).to start_with("Bearer ")
    end

    it "rejects invalid credentials" do
      post "/users/sign_in", params: { user: { email: "host@example.com", password: "wrong" } }, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /users/sign_out" do
    let(:user) { create(:user) }

    it "signs out the current token" do
      delete "/users/sign_out", headers: { "Authorization" => "Bearer #{user.generate_jwt}" }, as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "password reset" do
    before { create(:user, email: "host@example.com") }

    it "accepts a reset request without revealing whether the email exists" do
      post "/users/password", params: { user: { email: "host@example.com" } }, as: :json
      expect(response).to have_http_status(:ok)
    end

    it "rejects a reset perform with an invalid token" do
      put "/users/password",
        params: { user: { reset_password_token: "bogus", password: "newpassword1", password_confirmation: "newpassword1" } },
        as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "multi-device sessions" do
    let(:user) { create(:user) }
    let(:phone) { user.generate_jwt }
    let(:laptop) { user.generate_jwt }

    def me_id(token)
      post "/graphql", params: { query: "{ me { id } }" },
        headers: { "Authorization" => "Bearer #{token}" }, as: :json
      response.parsed_body.dig("data", "me", "id")
    end

    it "keeps every device authenticated after another device signs in", :aggregate_failures do
      expect(me_id(phone)).to eq(user.id.to_s)
      expect(me_id(laptop)).to eq(user.id.to_s)
    end

    it "revokes only the device that signs out", :aggregate_failures do
      delete "/users/sign_out", headers: { "Authorization" => "Bearer #{phone}" }, as: :json
      expect(response).to have_http_status(:ok)
      expect(me_id(phone)).to be_nil            # the signed-out device is rejected
      expect(me_id(laptop)).to eq(user.id.to_s) # the other device stays signed in
    end
  end

  describe "GraphQL authentication via Bearer token" do
    let(:user) { create(:user) }

    it "resolves me for a valid token" do
      post "/graphql", params: { query: "{ me { id } }" },
        headers: { "Authorization" => "Bearer #{user.generate_jwt}" }, as: :json
      expect(response.parsed_body.dig("data", "me", "id")).to eq(user.id.to_s)
    end

    it "ignores an invalid token (me is null)" do
      post "/graphql", params: { query: "{ me { id } }" },
        headers: { "Authorization" => "Bearer not.a.jwt" }, as: :json
      expect(response.parsed_body.dig("data", "me")).to be_nil
    end
  end
end
