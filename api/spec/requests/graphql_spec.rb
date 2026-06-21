require "rails_helper"

RSpec.describe "GraphQL endpoint", type: :request do
  it "serves the API root", :aggregate_failures do
    get "/"
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["message"]).to eq("Davey's Coffee API")
  end

  it "resolves the apiVersion query (variables omitted)", :aggregate_failures do
    post "/graphql", params: { query: "{ apiVersion }" }
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig("data", "apiVersion")).to eq("0.1.0")
  end

  it "resolves the ping mutation" do
    post "/graphql", params: { query: "mutation { ping }" }
    expect(response.parsed_body.dig("data", "ping")).to be(true)
  end

  it "accepts variables as a JSON string" do
    post "/graphql", params: { query: "{ apiVersion }", variables: "{}" }
    expect(response.parsed_body.dig("data", "apiVersion")).to eq("0.1.0")
  end

  it "accepts a blank variables string" do
    post "/graphql", params: { query: "{ apiVersion }", variables: "" }
    expect(response.parsed_body.dig("data", "apiVersion")).to eq("0.1.0")
  end

  it "accepts variables as a nested hash (ActionController::Parameters)" do
    post "/graphql", params: { query: "{ apiVersion }", variables: { foo: "bar" } }
    expect(response.parsed_body.dig("data", "apiVersion")).to eq("0.1.0")
  end

  it "renders the error with a backtrace in development when execution raises", :aggregate_failures do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
    allow(ApiSchema).to receive(:execute).and_raise(StandardError, "boom")

    post "/graphql", params: { query: "{ apiVersion }" }

    expect(response).to have_http_status(:internal_server_error)
    expect(response.parsed_body.dig("errors", 0, "message")).to eq("boom")
  end
end
