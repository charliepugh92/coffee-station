require "rails_helper"

RSpec.describe "Orders", type: :graphql do
  let(:user) { create(:user) }
  let(:station) { create(:station, user:) }
  let(:session) { create(:session, station:) }

  describe "createOrder (guest, public)" do
    let(:q) do
      "mutation($t: String!, $a: OrderInput!) " \
        "{ createOrder(input: { sessionToken: $t, attrs: $a }) " \
        "{ order { id queuePosition memory { groups { category options } } } guestToken errors } }"
    end

    def place(token, attrs = { "guestName" => "Sam" })
      execute_query(q, variables: { "t" => token, "a" => attrs }, context: {})
    end

    def remembered_options(result)
      gql_data(result, "createOrder", "order", "memory", "groups").flat_map { |g| g["options"] }
    end

    it "places an order and returns a guest token", :aggregate_failures do
      result = place(session.share_token)
      expect(gql_data(result, "createOrder", "guestToken")).to be_present
      expect(gql_data(result, "createOrder", "order", "queuePosition")).to eq(1)
    end

    it "only remembers options that belong to the station" do
      mine = create(:customization_option, customization_category: create(:customization_category, station:))
      foreign = create(:customization_option)
      result = place(session.share_token, { "guestName" => "Sam", "optionIds" => [ mine.id, foreign.id ] })
      expect(remembered_options(result)).to eq([ mine.name ])
    end

    it "rejects orders on a closed session" do
      session.close!
      expect(gql_data(place(session.share_token), "createOrder", "errors")).to include("This station is closed")
    end

    it "rejects an invalid session token" do
      expect(gql_data(place("nope"), "createOrder", "errors")).to include("This coffee link isn't valid")
    end
  end

  describe "createOrder with a base" do
    let(:base) { create(:base, station:) }
    let(:bq) do
      "mutation($t: String!, $a: OrderInput!) { createOrder(input: { sessionToken: $t, attrs: $a }) " \
        "{ order { memory { baseName groups { category options } } } errors } }"
    end

    it "remembers only options from categories the base enables", :aggregate_failures do
      on = create(:customization_option, customization_category: create(:customization_category, station:).tap { |c| base.customization_categories << c })
      off = create(:customization_option, customization_category: create(:customization_category, station:))
      result = execute_query(bq, variables: { "t" => session.share_token, "a" => { "guestName" => "Sam", "baseId" => base.id, "optionIds" => [ on.id, off.id ] } }, context: {})
      expect(gql_data(result, "createOrder", "order", "memory", "groups").flat_map { |g| g["options"] }).to eq([ on.name ])
      expect(gql_data(result, "createOrder", "order", "memory", "baseName")).to eq(base.name)
    end
  end

  describe "deleteOrder (host)" do
    let(:q) { "mutation($id: ID!) { deleteOrder(input: { orderId: $id }) { success errors } }" }
    let(:order) do
      create(:order, session:).tap do |o|
        o.completion_photo.attach(io: File.open(Rails.root.join("spec/fixtures/files/test_image.png")),
          filename: "done.png", content_type: "image/png")
      end
    end

    it "deletes the order and removes its photo attachment", :aggregate_failures do
      result = execute_query(q, variables: { "id" => order.id }, context: auth_context(user))
      expect(gql_data(result, "deleteOrder", "success")).to be(true)
      expect(Order.exists?(order.id)).to be(false)
      expect(ActiveStorage::Attachment.where(record_type: "Order", record_id: order.id)).to be_empty
    end

    it "refuses to delete another host's order" do
      result = execute_query(q, variables: { "id" => create(:order).id }, context: auth_context(user))
      expect(gql_errors(result).first["message"]).to eq("Order not found")
    end
  end

  describe "orderHistory (host)" do
    let(:q) { "query($s: ID) { orderHistory(stationId: $s) { id stationId } }" }
    let!(:mine) { create(:order, session:) }

    before { create(:order) } # another host's order, never visible

    it "returns the host's orders across all their stations" do
      elsewhere = create(:order, session: create(:session, station: create(:station, user:)))
      result = execute_query(q, variables: {}, context: auth_context(user))
      expect(gql_data(result, "orderHistory").map { |o| o["id"] }).to contain_exactly(mine.id.to_s, elsewhere.id.to_s)
    end

    it "filters by station" do
      result = execute_query(q, variables: { "s" => station.id }, context: auth_context(user))
      expect(gql_data(result, "orderHistory").map { |o| o["id"] }).to eq([ mine.id.to_s ])
    end

    it "returns nothing when unauthenticated" do
      result = execute_query(q, variables: {}, context: {})
      expect(gql_data(result, "orderHistory")).to eq([])
    end
  end

  describe "orderByToken (public)" do
    it "never exposes the guest token as a readable field" do
      result = execute_query("query($t: String!) { orderByToken(token: $t) { guestToken } }",
        variables: { "t" => "x" }, context: {})
      expect(gql_errors(result)).not_to be_empty
    end
  end

  describe "updateOrderStatus (host)" do
    let(:q) { "mutation($id: ID!, $s: OrderStatusEnum!) { updateOrderStatus(input: { orderId: $id, status: $s }) { order { status } errors } }" }

    it "advances the host's own order" do
      order = create(:order, session:)
      result = execute_query(q, variables: { "id" => order.id, "s" => "IN_PROGRESS" }, context: auth_context(user))
      expect(gql_data(result, "updateOrderStatus", "order", "status")).to eq("IN_PROGRESS")
    end

    it "refuses to touch another host's order" do
      result = execute_query(q, variables: { "id" => create(:order).id, "s" => "READY" }, context: auth_context(user))
      expect(gql_errors(result).first["message"]).to eq("Order not found")
    end
  end

  describe "session.orders visibility" do
    let(:q) { "query($t: String!) { sessionByToken(token: $t) { orders { id } } }" }

    it "shows orders to the owning host but not to guests", :aggregate_failures do
      create(:order, session:)
      as_guest = execute_query(q, variables: { "t" => session.share_token }, context: {})
      as_host = execute_query(q, variables: { "t" => session.share_token }, context: auth_context(user))
      expect(gql_data(as_guest, "sessionByToken", "orders")).to eq([])
      expect(gql_data(as_host, "sessionByToken", "orders").size).to eq(1)
    end
  end
end
