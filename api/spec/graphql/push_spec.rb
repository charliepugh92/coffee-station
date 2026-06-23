require "rails_helper"

RSpec.describe "Push", type: :graphql do
  let(:user) { create(:user) }
  let(:station) { create(:station, user:) }
  let(:session) { create(:session, station:) }

  describe "registerHostPushSubscription" do
    let(:q) do
      "mutation($e: String!, $p: String!, $a: String!) " \
        "{ registerHostPushSubscription(input: { endpoint: $e, p256dh: $p, auth: $a }) { success errors } }"
    end

    def register(context)
      execute_query(q, variables: { "e" => "https://push/host", "p" => "p", "a" => "a" }, context:)
    end

    it "registers a device for the authenticated host", :aggregate_failures do
      expect(gql_data(register(auth_context(user)), "registerHostPushSubscription", "success")).to be(true)
      expect(user.push_subscriptions.pluck(:endpoint)).to eq([ "https://push/host" ])
    end

    it "requires authentication" do
      expect(gql_errors(register({})).first["message"]).to eq("Authentication required")
    end
  end

  describe "registerGuestPushSubscription" do
    let(:order) { create(:order, session:) }
    let(:q) do
      "mutation($t: String!, $e: String!, $p: String!, $a: String!) " \
        "{ registerGuestPushSubscription(input: { orderToken: $t, endpoint: $e, p256dh: $p, auth: $a }) { success errors } }"
    end

    def register(token)
      execute_query(q, variables: { "t" => token, "e" => "https://push/guest", "p" => "p", "a" => "a" }, context: {})
    end

    it "registers a device against the matching order", :aggregate_failures do
      expect(gql_data(register(order.guest_token), "registerGuestPushSubscription", "success")).to be(true)
      expect(order.push_subscriptions.pluck(:endpoint)).to eq([ "https://push/guest" ])
    end

    it "rejects an unknown order token" do
      expect(gql_data(register("nope"), "registerGuestPushSubscription", "errors")).to include("Order not found")
    end
  end

  describe "unregisterPushSubscription" do
    let(:q) { "mutation($e: String!) { unregisterPushSubscription(input: { endpoint: $e }) { success } }" }

    it "deletes the subscription by endpoint" do
      PushSubscription.register(subscriber: user, endpoint: "https://push/gone", p256dh: "p", auth: "a")
      execute_query(q, variables: { "e" => "https://push/gone" }, context: {})
      expect(PushSubscription.exists?(endpoint: "https://push/gone")).to be(false)
    end
  end

  describe "vapidPublicKey" do
    it "exposes the server's VAPID public key" do
      result = execute_query("query { vapidPublicKey }", context: {})
      expect(gql_data(result, "vapidPublicKey")).to be_present
    end
  end

  describe "push delivery hooks" do
    def create_q
      "mutation($t: String!, $a: OrderInput!) { createOrder(input: { sessionToken: $t, attrs: $a }) { guestToken errors } }"
    end

    def status_q
      "mutation($id: ID!, $s: OrderStatusEnum!) { updateOrderStatus(input: { orderId: $id, status: $s }) { order { status } } }"
    end

    def complete_q
      "mutation($id: ID!, $f: Upload!) { completeOrder(input: { orderId: $id, file: $f }) { order { status } } }"
    end

    def photo
      ApolloUploadServer::Wrappers::UploadedFile.new(
        ActionDispatch::Http::UploadedFile.new(
          tempfile: File.open(Rails.root.join("spec/fixtures/files/test_image.png")),
          filename: "done.png", type: "image/png"
        )
      )
    end

    before { allow(WebPushSender).to receive(:deliver) }

    it "delivers a host push when a guest places an order" do
      PushSubscription.register(subscriber: user, endpoint: "https://push/host", p256dh: "p", auth: "a")
      execute_query(create_q, variables: { "t" => session.share_token, "a" => { "guestName" => "Sam" } }, context: {})
      expect(WebPushSender).to have_received(:deliver).with(having_attributes(endpoint: "https://push/host"), anything)
    end

    it "delivers a guest push when the order is marked ready" do
      order = create(:order, session:, status: :in_progress)
      PushSubscription.register(subscriber: order, endpoint: "https://push/guest", p256dh: "p", auth: "a")
      execute_query(complete_q, variables: { "id" => order.id, "f" => photo }, context: auth_context(user))
      expect(WebPushSender).to have_received(:deliver).with(having_attributes(endpoint: "https://push/guest"), anything)
    end

    it "does NOT push the guest on a non-ready status change" do
      order = create(:order, session:, status: :pending)
      PushSubscription.register(subscriber: order, endpoint: "https://push/guest", p256dh: "p", auth: "a")
      execute_query(status_q, variables: { "id" => order.id, "s" => "IN_PROGRESS" }, context: auth_context(user))
      expect(WebPushSender).not_to have_received(:deliver)
    end
  end
end
