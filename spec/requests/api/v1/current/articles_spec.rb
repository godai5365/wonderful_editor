require "rails_helper"

RSpec.describe "Api::V1::Current::Articles" do
  describe "GET /api_v1_current_articles" do
    subject { get(api_v1_current_articles_path, headers: headers) }

    let(:headers) { current_user.create_new_auth_token }
    let(:current_user) { create(:user) }

    context "下書き及び公開状態の記事が複数ある場合" do
      let!(:aaa_article1) { create(:article, :published, user: current_user, updated_at: 1.days.ago) } # 2/18 修正
      let!(:bbb_article2) { create(:article, :published, user: current_user, updated_at: 2.days.ago) } # 2/18 修正
      let!(:ccc_article3) { create(:article, :published, user: current_user) } # 2/18 修正

      # 事前に下書き状態の記事を作成しておく
      before do
        create(:article, :draft, user: current_user, updated_at: 1.days.ago) # 2/18 修正
        create(:article, :draft, user: current_user, updated_at: 2.days.ago) # 2/18 修正
        create(:article, :draft) # 2/18 修正
      end

      it "自分で書いた公開状態の記事を取得できる" do
        subject
        expect(response).to have_http_status(:ok)
        res = response.parsed_body
        expect(res.length).to eq 3
        expect(res.pluck("id")).to eq [ccc_article3.id, aaa_article1.id, bbb_article2.id]
        expect(res[0].keys).to eq ["id", "title", "status", "updated_at", "user"]
        expect(res[0]["user"]["id"]).to eq current_user.id
        expect(res[0]["user"].keys).to eq ["id", "name", "email"]
      end
    end
  end
end
