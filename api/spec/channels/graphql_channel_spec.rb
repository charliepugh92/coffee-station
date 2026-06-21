require "rails_helper"

RSpec.describe GraphqlChannel, type: :channel do
  let(:sub_query) { "subscription($t: String!) { sessionUpdated(sessionToken: $t) { session { id } } }" }

  it "executes a plain query and replies once" do
    subscribe
    perform("execute", { "query" => "{ apiVersion }" })
    expect(transmissions.last["result"]["data"]["apiVersion"]).to eq("0.1.0")
  end

  it "registers a subscription and tears it down on unsubscribe", :aggregate_failures do
    session = create(:session)
    subscribe
    perform("execute", "query" => sub_query, "variables" => { "t" => session.share_token })
    expect(transmissions.last["more"]).to be(true)
    expect { unsubscribe }.not_to raise_error
  end
end
