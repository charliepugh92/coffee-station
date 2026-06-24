require "rails_helper"

RSpec.describe "completeOrder", type: :graphql do
  let(:user) { create(:user) }
  let(:order) { create(:order, session: create(:session, station: create(:station, user:))) }
  let(:q) { "mutation($id: ID!, $f: Upload!) { completeOrder(input: { orderId: $id, file: $f }) { order { status completionPhotoUrl } errors } }" }

  def photo
    ApolloUploadServer::Wrappers::UploadedFile.new(
      ActionDispatch::Http::UploadedFile.new(
        tempfile: File.open(Rails.root.join("spec/fixtures/files/test_image.png")),
        filename: "done.png", type: "image/png"
      )
    )
  end

  it "marks the order ready and attaches the photo", :aggregate_failures do
    result = execute_query(q, variables: { "id" => order.id, "f" => photo }, context: auth_context(user))
    expect(gql_data(result, "completeOrder", "order", "status")).to eq("READY")
    expect(gql_data(result, "completeOrder", "order", "completionPhotoUrl")).to include("/rails/active_storage/")
  end

  it "marks the order ready without a photo", :aggregate_failures do
    no_photo_q = "mutation($id: ID!) { completeOrder(input: { orderId: $id }) { order { status completionPhotoUrl } errors } }"
    result = execute_query(no_photo_q, variables: { "id" => order.id }, context: auth_context(user))
    expect(gql_data(result, "completeOrder", "order", "status")).to eq("READY")
    expect(gql_data(result, "completeOrder", "order", "completionPhotoUrl")).to be_nil
  end

  it "refuses to complete another host's order" do
    foreign = create(:order)
    result = execute_query(q, variables: { "id" => foreign.id, "f" => photo }, context: auth_context(user))
    expect(gql_errors(result).first["message"]).to eq("Order not found")
  end
end
