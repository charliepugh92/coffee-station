require "rails_helper"

RSpec.describe "Sessions", type: :graphql do
  let(:user) { create(:user) }
  let(:station) { create(:station, user:) }

  describe "openSession" do
    let(:q) { "mutation($s: ID!) { openSession(input: { stationId: $s }) { session { status shareToken } errors } }" }

    def open(station_id, ctx: auth_context(user))
      execute_query(q, variables: { "s" => station_id }, context: ctx)
    end

    it "opens a station and returns the share token to the host" do
      result = open(station.id)
      expect(gql_data(result, "openSession", "session", "shareToken")).to be_present
    end

    it "refuses to open a station that is already open" do
      create(:session, station:)
      expect(gql_data(open(station.id), "openSession", "errors")).to include("Station is already open")
    end

    it "refuses to open another host's station" do
      expect(gql_errors(open(create(:station).id)).first["message"]).to eq("Station not found")
    end
  end

  describe "closeSession" do
    it "closes the host's open session" do
      session = create(:session, station:)
      q = "mutation($id: ID!) { closeSession(input: { id: $id }) { session { status } errors } }"
      result = execute_query(q, variables: { "id" => session.id }, context: auth_context(user))
      expect(gql_data(result, "closeSession", "session", "status")).to eq("CLOSED")
    end
  end

  describe "sessionByToken (public)" do
    let(:session) { create(:session, station:) }
    let(:q) { "query($t: String!) { sessionByToken(token: $t) { status shareToken station { name } } }" }

    it "returns the menu to a guest but hides the share token", :aggregate_failures do
      result = execute_query(q, variables: { "t" => session.share_token }, context: {})
      expect(gql_data(result, "sessionByToken", "station", "name")).to eq(station.name)
      expect(gql_data(result, "sessionByToken", "shareToken")).to be_nil
    end

    it "exposes the share token to the owning host" do
      result = execute_query(q, variables: { "t" => session.share_token }, context: auth_context(user))
      expect(gql_data(result, "sessionByToken", "shareToken")).to eq(session.share_token)
    end
  end
end
