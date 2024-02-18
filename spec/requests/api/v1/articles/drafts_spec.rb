require "rails_helper"

RSpec.describe "Api::V1::Articles::Drafts" do
  describe "GET /api/v1/articles/drafts" do
    subject { get(api_v1_articles_drafts_path, headers: headers) }

    let(:headers) { current_user.create_new_auth_token }
    let(:current_user) { create(:user) }

    context "自分で書いた下書き状態の記事が存在する場合" do
      let!(:aaa_article1) { create(:article, :draft, user: current_user, updated_at: 1.days.ago) } # 2/18 修正
      let!(:bbb_article2) { create(:article, :draft, user: current_user, updated_at: 2.days.ago) } # 2/18 修正
      let!(:ccc_article3) { create(:article, :draft, user: current_user) } # 2/18 修正
      let!(:ddd_article4) { create(:article, :draft) }

      it "下書き状態の記事のみが一覧が取得できる" do
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

  describe "GET /api_v1_articles_draft" do
    subject { get(api_v1_articles_draft_path(article.id), headers: headers) }

    let(:headers) { current_user.create_new_auth_token }
    let(:current_user) { create(:user) }

    context "指定した id の記事が存在する場合" do
      context "指定した記事が自分の下書きの場合" do
        let(:article) { create(:article, :draft, user: current_user) }

        it "記事を取得できる" do
          subject
          res = response.parsed_body

          expect(response).to have_http_status(:ok)
          expect(res["id"]).to eq article.id
          expect(res["title"]).to eq article.title
          expect(res["body"]).to eq article.body
          expect(res["status"]).to eq article.status
          expect(res["updated_at"]).to be_present
          expect(res["user"]["id"]).to eq article.user.id
          expect(res["user"].keys).to eq ["id", "name", "email"]
        end
      end

      context "指定した記事が他者の下書きの場合" do
        let(:article) { create(:article, :draft) }
        it "記事を取得できない" do
          expect { subject }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "指定した記事が公開状態の場合" do
        let(:article) { create(:article, :published, user: current_user) }
        it "記事を取得できない" do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
