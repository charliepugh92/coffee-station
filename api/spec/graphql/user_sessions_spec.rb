require "rails_helper"

RSpec.describe "User sessions (devices)", type: :graphql do
  let(:user) { create(:user) }

  describe "Query: me { sessions }" do
    let!(:older) { user.user_sessions.create!(jti: SecureRandom.uuid, exp: 1.day.from_now, last_active_at: 2.hours.ago) }
    let!(:current) { user.user_sessions.create!(jti: SecureRandom.uuid, exp: 1.day.from_now, last_active_at: 1.minute.ago) }

    it "lists devices newest-first and flags the caller's own", :aggregate_failures do
      result = execute_query("{ me { sessions { id current } } }", context: { current_user: user, current_jti: current.jti })
      sessions = gql_data(result, "me", "sessions")
      expect(sessions.map { |s| s["id"] }).to eq([ current.id.to_s, older.id.to_s ])
      expect(sessions.map { |s| s["current"] }).to eq([ true, false ])
    end
  end

  describe "Mutation: revokeSession" do
    let(:mutation) do
      <<~GQL
        mutation($id: ID!) {
          revokeSession(input: { sessionId: $id }) { success errors }
        }
      GQL
    end

    it "revokes one of the host's own devices", :aggregate_failures do
      session = user.user_sessions.create!(jti: SecureRandom.uuid, exp: 1.day.from_now)

      result = execute_query(mutation, variables: { id: session.id.to_s }, context: { current_user: user })

      expect(gql_data(result, "revokeSession", "success")).to be(true)
      expect(user.user_sessions.exists?(session.id)).to be(false)
    end

    it "does not revoke another host's device", :aggregate_failures do
      other = create(:user).user_sessions.create!(jti: SecureRandom.uuid, exp: 1.day.from_now)

      result = execute_query(mutation, variables: { id: other.id.to_s }, context: { current_user: user })

      expect(gql_data(result, "revokeSession", "success")).to be(false)
      expect(UserSession.exists?(other.id)).to be(true)
    end

    it "requires authentication" do
      session = user.user_sessions.create!(jti: SecureRandom.uuid, exp: 1.day.from_now)
      result = execute_query(mutation, variables: { id: session.id.to_s }, context: {})
      expect(gql_errors(result)).to be_present
    end
  end
end
