require "rails_helper"

RSpec.describe "Subscriptions", type: :graphql do
  let(:station) { create(:station) }
  let(:session) { create(:session, station:) }

  describe "orderAdded" do
    let(:q) { "subscription($t: String!) { orderAdded(sessionToken: $t) { order { id } } }" }

    it "subscribes with a valid session token" do
      result = execute_query(q, variables: { "t" => session.share_token }, context: subscription_context)
      expect(gql_errors(result)).to be_empty
    end

    it "rejects an unknown session token" do
      result = execute_query(q, variables: { "t" => "nope" }, context: subscription_context)
      expect(gql_errors(result).first["message"]).to eq("Session not found")
    end
  end

  describe "orderUpdated" do
    let(:q) { "subscription($t: String!) { orderUpdated(orderToken: $t) { order { id } } }" }

    it "subscribes with a valid order token" do
      order = create(:order, session:)
      result = execute_query(q, variables: { "t" => order.guest_token }, context: subscription_context)
      expect(gql_errors(result)).to be_empty
    end

    it "rejects an unknown order token" do
      result = execute_query(q, variables: { "t" => "nope" }, context: subscription_context)
      expect(gql_errors(result).first["message"]).to eq("Order not found")
    end
  end

  describe "sessionUpdated" do
    let(:q) { "subscription($t: String!) { sessionUpdated(sessionToken: $t) { session { id } } }" }

    it "subscribes with a valid session token" do
      result = execute_query(q, variables: { "t" => session.share_token }, context: subscription_context)
      expect(gql_errors(result)).to be_empty
    end

    it "rejects an unknown session token" do
      result = execute_query(q, variables: { "t" => "x" }, context: subscription_context)
      expect(gql_errors(result).first["message"]).to eq("Session not found")
    end
  end
end
