require "rails_helper"

RSpec.describe "Stations", type: :graphql do
  let(:user) { create(:user) }

  def create_station(attrs, ctx: auth_context(user))
    q = "mutation($a: StationAttrsInput!) { createStation(input: { attrs: $a }) { station { id name slug } errors } }"
    execute_query(q, variables: { "a" => attrs }, context: ctx)
  end

  describe "createStation" do
    it "creates a station for the host" do
      result = create_station({ "name" => "Morning Bar", "slug" => "morning-bar" })
      expect(gql_data(result, "createStation", "station", "name")).to eq("Morning Bar")
    end

    it "requires authentication" do
      result = create_station({ "name" => "X" }, ctx: {})
      expect(gql_errors(result).first["message"]).to eq("Authentication required")
    end

    it "returns validation errors for a blank name" do
      result = create_station({ "name" => "" })
      expect(gql_data(result, "createStation", "errors")).to be_present
    end
  end

  describe "myStations" do
    it "returns only the current host's stations" do
      mine = create(:station, user:)
      create(:station)
      result = execute_query("{ myStations { id } }", context: auth_context(user))
      expect(gql_data(result, "myStations").map { |s| s["id"] }).to eq([ mine.id.to_s ])
    end

    it "is empty when unauthenticated" do
      expect(gql_data(execute_query("{ myStations { id } }", context: {}), "myStations")).to eq([])
    end
  end

  describe "updateStation / ownership" do
    let(:q) { "mutation($id: ID!, $a: StationAttrsInput!) { updateStation(input: { id: $id, attrs: $a }) { station { name } errors } }" }

    def update(id)
      execute_query(q, variables: { "id" => id, "a" => { "name" => "Renamed" } }, context: auth_context(user))
    end

    it "updates the host's own station" do
      station = create(:station, user:)
      expect(gql_data(update(station.id), "updateStation", "station", "name")).to eq("Renamed")
    end

    it "refuses to update another host's station" do
      expect(gql_errors(update(create(:station).id)).first["message"]).to eq("Station not found")
    end
  end

  describe "deleteStation" do
    it "deletes the host's own station" do
      station = create(:station, user:)
      q = "mutation($id: ID!) { deleteStation(input: { id: $id }) { success } }"
      result = execute_query(q, variables: { "id" => station.id }, context: auth_context(user))
      expect(gql_data(result, "deleteStation", "success")).to be(true)
    end
  end
end
