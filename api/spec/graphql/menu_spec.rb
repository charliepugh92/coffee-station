require "rails_helper"

RSpec.describe "Menu building", type: :graphql do
  let(:user) { create(:user) }
  let(:station) { create(:station, user:) }

  def run(query, vars)
    execute_query(query, variables: vars, context: auth_context(user))
  end

  def upload_file
    ApolloUploadServer::Wrappers::UploadedFile.new(
      ActionDispatch::Http::UploadedFile.new(
        tempfile: File.open(Rails.root.join("spec/fixtures/files/test_image.png")),
        filename: "test_image.png", type: "image/png"
      )
    )
  end

  describe "categories" do
    let(:q) { "mutation($s: ID!, $id: ID, $a: CategoryAttrsInput!) { upsertCategory(input: { stationId: $s, id: $id, attrs: $a }) { category { id name } errors } }" }

    it "creates a category" do
      result = run(q, { "s" => station.id, "a" => { "name" => "Milk", "selectionMode" => "SINGLE" } })
      expect(gql_data(result, "upsertCategory", "category", "name")).to eq("Milk")
    end

    it "updates an existing category" do
      cat = create(:customization_category, station:)
      result = run(q, { "s" => station.id, "id" => cat.id, "a" => { "name" => "Renamed" } })
      expect(gql_data(result, "upsertCategory", "category", "name")).to eq("Renamed")
    end

    it "reorders categories" do
      c1 = create(:customization_category, station:, position: 0)
      c2 = create(:customization_category, station:, position: 1)
      reorder = "mutation($s: ID!, $ids: [ID!]!) { reorderCategories(input: { stationId: $s, orderedIds: $ids }) { categories { id } } }"
      result = run(reorder, { "s" => station.id, "ids" => [ c2.id, c1.id ] })
      expect(gql_data(result, "reorderCategories", "categories").map { |c| c["id"] }).to eq([ c2.id.to_s, c1.id.to_s ])
    end

    it "deletes a category" do
      cat = create(:customization_category, station:)
      result = run("mutation($id: ID!) { deleteCategory(input: { id: $id }) { success } }", { "id" => cat.id })
      expect(gql_data(result, "deleteCategory", "success")).to be(true)
    end
  end

  describe "options" do
    let(:category) { create(:customization_category, station:) }

    it "creates an option with a surcharge" do
      q = "mutation($c: ID!, $a: OptionAttrsInput!) { upsertOption(input: { categoryId: $c, attrs: $a }) { option { surchargeCents } errors } }"
      result = run(q, { "c" => category.id, "a" => { "name" => "Oat", "surchargeCents" => 75 } })
      expect(gql_data(result, "upsertOption", "option", "surchargeCents")).to eq(75)
    end

    it "deletes an option" do
      option = create(:customization_option, customization_category: category)
      result = run("mutation($id: ID!) { deleteOption(input: { id: $id }) { success } }", { "id" => option.id })
      expect(gql_data(result, "deleteOption", "success")).to be(true)
    end

    it "attaches an image and exposes its URL" do
      option = create(:customization_option, customization_category: category)
      q = "mutation($id: ID!, $f: Upload!) { uploadOptionImage(input: { optionId: $id, file: $f }) { option { imageUrl } } }"
      result = run(q, { "id" => option.id, "f" => upload_file })
      expect(gql_data(result, "uploadOptionImage", "option", "imageUrl")).to include("/rails/active_storage/")
    end
  end

  describe "presets" do
    let(:category) { create(:customization_category, station:) }
    let(:upsert) { "mutation($s: ID!, $a: PresetAttrsInput!, $ids: [ID!]) { upsertPreset(input: { stationId: $s, attrs: $a, optionIds: $ids }) { preset { id options { id } } errors } }" }

    it "bundles only this station's options" do
      mine = create(:customization_option, customization_category: category)
      foreign = create(:customization_option)
      result = run(upsert, { "s" => station.id, "a" => { "name" => "House Special" }, "ids" => [ mine.id, foreign.id ] })
      expect(gql_data(result, "upsertPreset", "preset", "options").map { |o| o["id"] }).to eq([ mine.id.to_s ])
    end

    it "attaches a preset image" do
      preset = create(:menu_preset, station:)
      q = "mutation($id: ID!, $f: Upload!) { uploadPresetImage(input: { presetId: $id, file: $f }) { preset { imageUrl } } }"
      result = run(q, { "id" => preset.id, "f" => upload_file })
      expect(gql_data(result, "uploadPresetImage", "preset", "imageUrl")).to include("/rails/active_storage/")
    end

    it "deletes a preset" do
      preset = create(:menu_preset, station:)
      result = run("mutation($id: ID!) { deletePreset(input: { id: $id }) { success } }", { "id" => preset.id })
      expect(gql_data(result, "deletePreset", "success")).to be(true)
    end
  end

  describe "bases" do
    let(:upsert) { "mutation($s: ID!, $id: ID, $a: BaseAttrsInput!, $cids: [ID!]) { upsertBase(input: { stationId: $s, id: $id, attrs: $a, categoryIds: $cids }) { base { id name surchargeCents categories { id } } errors } }" }
    let(:mine) { create(:customization_category, station:) }

    it "creates a base enabling only this station's categories", :aggregate_failures do
      result = run(upsert, { "s" => station.id, "a" => { "name" => "Latte", "surchargeCents" => 50 }, "cids" => [ mine.id, create(:customization_category).id ] })
      expect(gql_data(result, "upsertBase", "base", "surchargeCents")).to eq(50)
      expect(gql_data(result, "upsertBase", "base", "categories").map { |c| c["id"] }).to eq([ mine.id.to_s ])
    end

    it "updates a base's enabled categories" do
      base = create(:base, station:)
      cat = create(:customization_category, station:)
      result = run(upsert, { "s" => station.id, "id" => base.id, "a" => { "name" => "Cappuccino" }, "cids" => [ cat.id ] })
      expect(gql_data(result, "upsertBase", "base", "categories").map { |c| c["id"] }).to eq([ cat.id.to_s ])
    end

    it "attaches a base image" do
      base = create(:base, station:)
      q = "mutation($id: ID!, $f: Upload!) { uploadBaseImage(input: { baseId: $id, file: $f }) { base { imageUrl } } }"
      result = run(q, { "id" => base.id, "f" => upload_file })
      expect(gql_data(result, "uploadBaseImage", "base", "imageUrl")).to include("/rails/active_storage/")
    end

    it "deletes a base" do
      base = create(:base, station:)
      result = run("mutation($id: ID!) { deleteBase(input: { id: $id }) { success } }", { "id" => base.id })
      expect(gql_data(result, "deleteBase", "success")).to be(true)
    end
  end
end
