require "rails_helper"

RSpec.describe "Feedback", type: :graphql do
  let(:order) { create(:order) }

  describe "rateOrder" do
    let(:q) { "mutation($t: String!, $s: Int!) { rateOrder(input: { orderToken: $t, stars: $s }) { rating { stars } errors } }" }

    def rate(token, stars)
      execute_query(q, variables: { "t" => token, "s" => stars }, context: {})
    end

    it "saves a rating for the matching order token" do
      expect(gql_data(rate(order.guest_token, 4), "rateOrder", "rating", "stars")).to eq(4)
    end

    it "updates the existing rating instead of duplicating", :aggregate_failures do
      rate(order.guest_token, 3)
      expect(gql_data(rate(order.guest_token, 5), "rateOrder", "rating", "stars")).to eq(5)
      expect(order.reload.rating.stars).to eq(5)
    end

    it "rejects an out-of-range rating" do
      expect(gql_data(rate(order.guest_token, 9), "rateOrder", "errors")).to be_present
    end

    it "rejects an unknown order token" do
      expect(gql_data(rate("nope", 5), "rateOrder", "errors")).to include("Order not found")
    end
  end

  describe "addComment" do
    let(:q) { "mutation($t: String!, $b: String!) { addComment(input: { orderToken: $t, body: $b }) { comment { body } errors } }" }

    it "saves a comment for the matching order token" do
      result = execute_query(q, variables: { "t" => order.guest_token, "b" => "Loved it" }, context: {})
      expect(gql_data(result, "addComment", "comment", "body")).to eq("Loved it")
    end

    it "rejects an unknown order token" do
      result = execute_query(q, variables: { "t" => "nope", "b" => "x" }, context: {})
      expect(gql_data(result, "addComment", "errors")).to include("Order not found")
    end
  end
end
