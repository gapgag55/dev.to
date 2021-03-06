require "rails_helper"

RSpec.describe "ArticlesApi", type: :request do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }

  describe "GET /api/articles" do
    it "returns json response" do
      get "/api/articles"
      expect(response.content_type).to eq("application/json")
    end

    it "returns featured articles with no params" do
      create(:article)
      create(:article, featured: true)
      create(:article, featured: true)
      get "/api/articles"
      expect(JSON.parse(response.body).size).to eq(2)
    end

    it "returns user articles if username param is present" do
      create(:article, user_id: user1.id)
      create(:article, user_id: user1.id)
      create(:article, user_id: user2.id)
      get "/api/articles?username=#{user1.username}"
      expect(JSON.parse(response.body).size).to eq(2)
    end

    # rubocop:disable RSpec/ExampleLength
    it "returns organization articles if username param is present" do
      org = create(:organization)
      create(:article, user_id: user1.id)
      create(:article, user_id: user1.id, organization_id: org.id)
      create(:article, user_id: user1.id, organization_id: org.id)
      create(:article, user_id: user1.id)
      create(:article, user_id: user2.id)
      get "/api/articles?username=#{org.slug}"
      expect(JSON.parse(response.body).size).to eq(2)
    end
    # rubocop:enable RSpec/ExampleLength

    it "returns tag articles if tag param is present" do
      article = create(:article)
      get "/api/articles?tag=#{article.tag_list.first}"
      expect(JSON.parse(response.body).size).to eq(1)
    end

    it "returns not tag articles if article and tag are not approved" do
      article = create(:article, approved: false)
      tag = Tag.find_by_name(article.tag_list.first)
      tag.update(requires_approval: true)
      get "/api/articles?tag=#{tag.name}"
      expect(JSON.parse(response.body).size).to eq(0)
    end
  end

  describe "GET /api/articles/:id" do
    it "data for article based on ID" do
      article = create(:article)
      get "/api/articles/#{article.id}"
      expect(JSON.parse(response.body)["title"]).to eq(article.title)
    end
  end
end
