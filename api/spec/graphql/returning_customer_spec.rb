require "rails_helper"

RSpec.describe "Returning customer", type: :graphql do
  let(:station) { create(:station) }
  let(:session) { create(:session, station:) }

  describe "ordersByTokens" do
    let(:q) { "query($t: [String!]!) { ordersByTokens(tokens: $t) { id } }" }

    it "returns only the orders whose tokens are supplied", :aggregate_failures do
      mine = create(:order, session:)
      create(:order, session:) # someone else's order, token not supplied
      result = execute_query(q, variables: { "t" => [ mine.guest_token ] }, context: {})
      expect(gql_data(result, "ordersByTokens").map { |o| o["id"] }).to eq([ mine.id.to_s ])
    end
  end

  describe "canReorder" do
    let(:q) { "query($t: String!) { orderByToken(token: $t) { canReorder } }" }

    it "is true while the station is open and false once closed", :aggregate_failures do
      order = create(:order, session:)
      expect(gql_data(execute_query(q, variables: { "t" => order.guest_token }, context: {}), "orderByToken", "canReorder")).to be(true)
      session.close!
      expect(gql_data(execute_query(q, variables: { "t" => order.guest_token }, context: {}), "orderByToken", "canReorder")).to be(false)
    end
  end

  describe "reorder" do
    let(:q) { "mutation($t: String!) { reorder(input: { orderToken: $t }) { order { id selections { id } } guestToken errors } }" }
    let(:option) { create(:customization_option, customization_category: create(:customization_category, station:)) }

    it "clones a past order's selections into the open session", :aggregate_failures do
      prior = create(:order, session:)
      prior.customization_options << option
      result = execute_query(q, variables: { "t" => prior.guest_token }, context: {})
      expect(gql_data(result, "reorder", "guestToken")).to be_present
      expect(gql_data(result, "reorder", "order", "selections").map { |o| o["id"] }).to eq([ option.id.to_s ])
    end

    it "refuses to reorder when the station is closed" do
      prior = create(:order, session:)
      session.close!
      expect(gql_data(execute_query(q, variables: { "t" => prior.guest_token }, context: {}), "reorder", "errors")).to include("This station is closed")
    end
  end
end
