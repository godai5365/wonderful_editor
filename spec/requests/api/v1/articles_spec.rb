require "rails_helper"

RSpec.describe "Api::V1::Articles" do
  describe "GET /articles" do
    subject { get(api_v1_articles_path) }

    let!(:aaa_article1) { create(:article, updated_at: 1.days.ago) }
    let!(:bbb_article2) { create(:article, updated_at: 2.days.ago) }
    let!(:ccc_article3) { create(:article) }

    it "httpステータスがOKである" do
      subject
      # binding.pry
      # res = JSON.parse(response.body)
      @res = response.parsed_body
      expect(response).to have_http_status(:ok)
    end

    it "記事が3つできる" do
      expect(@res.length).to eq 3
    end

    it "更新順になっている" do
      expect(@res.map.pluck("id")).to eq [ccc_article3.id, aaa_article1.id, bbb_article2.id]
    end

    it "返ってくるkeyがid, title, updated_at, userである" do
      expect(@res[0].keys).to eq ["id", "title", "updated_at", "user"]
    end

    it "返ってくるkeyがid, name, emailである" do
      expect(@res[0]["user"].keys).to eq ["id", "name", "email"]
    end
  end
end
