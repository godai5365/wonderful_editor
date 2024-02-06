require "rails_helper"

RSpec.describe "Api::V1::Articles" do
  describe "GET /articles" do
    subject { get(api_v1_articles_path) }

    let!(:aaa_article1) { create(:article, updated_at: 1.days.ago) }
    let!(:bbb_article2) { create(:article, updated_at: 2.days.ago) }
    let!(:ccc_article3) { create(:article) }

    it "記事の一覧が取得できる" do
      subject
      # res = JSON.parse(response.body)
      res = response.parsed_body

      aggregate_failures do
        expect(response).to have_http_status(:ok)
        expect(res.length).to eq 3
        expect(res.map.pluck("id")).to eq [ccc_article3.id, aaa_article1.id, bbb_article2.id]
        expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
        expect(res[0]["user"].keys).to eq ["id", "name", "email"]
      end
    end
  end

  describe "GET /articles/:id" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定した id の記事が存在する場合" do
      let(:article_id) { article.id }
      let(:article) { create(:article) }

      it "任意の記事の値が取得できる" do
        subject

        res = response.parsed_body

        aggregate_failures do
          # httpsステータスが:ok(200)であることをテスト
          expect(response).to have_http_status(:ok)

          # subject で API を叩いた時点でできた article と、API のレスポンスの値が同じであることテスト
          expect(res["id"]).to eq article.id
          expect(res["title"]).to eq article.title
          expect(res["body"]).to eq article.body

          # be_presentはarticleにはupdated_atが存在することを期待するテスト
          expect(res["updated_at"]).to be_present

          # subject で API を叩いた時点でできた user と、API のレスポンスの値が同じであることテスト
          expect(res["user"]["id"]).to eq article.user.id

          # 返ってきたユーザーのデータは、id,name,email の 3 つのデータを持つこと期待するテスト
          expect(res["user"].keys).to eq ["id", "name", "email"]
        end
      end
    end

    context "指定した id の記事が存在しない場合" do
      let(:article_id) { 10000 }

      it "記事が見つからない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
