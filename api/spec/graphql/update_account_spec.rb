require "rails_helper"

RSpec.describe "updateAccount", type: :graphql do
  let(:user) { create(:user, password: "beanjuice123") }
  let(:q) do
    "mutation($e: String, $d: String, $p: String, $cp: String!) " \
      "{ updateAccount(input: { email: $e, displayName: $d, password: $p, currentPassword: $cp }) " \
      "{ user { id email displayName } errors } }"
  end

  def update(vars)
    execute_query(q, variables: vars, context: auth_context(user))
  end

  it "updates email and display name with the correct current password", :aggregate_failures do
    update({ "e" => "new@example.com", "d" => "New Name", "cp" => "beanjuice123" })
    expect(user.reload.email).to eq("new@example.com")
    expect(user.display_name).to eq("New Name")
  end

  it "changes the password with the correct current password", :aggregate_failures do
    result = update({ "p" => "freshbeans456", "cp" => "beanjuice123" })
    expect(gql_data(result, "updateAccount", "errors")).to be_empty
    expect(user.reload.valid_password?("freshbeans456")).to be(true)
  end

  it "rejects a wrong current password", :aggregate_failures do
    result = update({ "e" => "nope@example.com", "cp" => "wrongpass" })
    expect(gql_data(result, "updateAccount", "errors")).to include("Current password is incorrect")
    expect(user.reload.email).not_to eq("nope@example.com")
  end

  it "surfaces validation errors (e.g. too-short password)" do
    result = update({ "p" => "ab", "cp" => "beanjuice123" })
    expect(gql_data(result, "updateAccount", "errors")).not_to be_empty
  end

  it "requires authentication" do
    result = execute_query(q, variables: { "cp" => "beanjuice123" }, context: {})
    expect(gql_errors(result).first["message"]).to eq("Authentication required")
  end
end
