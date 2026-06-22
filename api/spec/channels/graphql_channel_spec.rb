require "rails_helper"

RSpec.describe GraphqlChannel, type: :channel do
  let(:sub_query) { "subscription($t: String!) { sessionUpdated(sessionToken: $t) { session { id } } }" }

  it "executes a plain query and replies once" do
    subscribe
    perform("execute", { "query" => "{ apiVersion }" })
    expect(transmissions.last["result"]["data"]["apiVersion"]).to eq("0.1.0")
  end

  it "registers a subscription without transmitting an empty initial frame", :aggregate_failures do
    session = create(:session)
    subscribe
    perform("execute", "query" => sub_query, "variables" => { "t" => session.share_token })
    # The initial subscribe only registers the stream (`:no_response`); it carries
    # no data, so nothing should be sent — forwarding `{ "data" => {} }` makes the
    # Apollo client's cache choke.
    expect(transmissions).to be_empty
    expect { unsubscribe }.not_to raise_error
  end
end
