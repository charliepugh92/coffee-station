require "rails_helper"

RSpec.describe "Query: me", type: :graphql do
  let(:user) { create(:user) }

  it "returns the current user when authenticated", :aggregate_failures do
    result = execute_query("{ me { id email displayName createdAt } }", context: auth_context(user))
    expect(gql_data(result, "me", "id")).to eq(user.id.to_s)
    expect(gql_data(result, "me", "email")).to eq(user.email)
    expect(gql_data(result, "me", "displayName")).to eq(user.display_name)
  end

  it "returns null when unauthenticated" do
    result = execute_query("{ me { id } }", context: {})
    expect(gql_data(result, "me")).to be_nil
  end
end
