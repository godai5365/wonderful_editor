require "rails_helper"

RSpec.describe "Api::V1::Articles" do
  describe "GET /articles" do
    # indexメソッドを使用するためのpathを指定
    subject { get(api_v1_articles_path) }

    # 事前評価とも言えるlet!を使用し呼び出される前にarticleを作成する
    # updated_atをバラバラにすることでJsonで返ってくる値がcontrollerで定義した通りに更新順になる。
    # また必要な値を作成して返してくれる
    let!(:aaa_article1) { create(:article, updated_at: 1.days.ago) }
    let!(:bbb_article2) { create(:article, updated_at: 2.days.ago) }
    let!(:ccc_article3) { create(:article) }

    it "記事の一覧が取得できる" do
      subject
      # res = JSON.parse(response.body)
      res = response.parsed_body
      # binding.pry
      aggregate_failures do
        # httpsステータスが:ok(200)であることをテスト
        expect(response).to have_http_status(:ok)
        # expect(response).to have_http_status(200)は上記と同義

        # レスポンスの長さが "3" であることをテスト
        expect(res.length).to eq 3

        # 取得した配列のidがarticle3,article1,article2の順番であることをテスト
        # expect(res.map {|d| d["id"] }).to eq [ccc_article3.id, aaa_article1.id, bbb_article2.id]
        expect(res.pluck("id")).to eq [ccc_article3.id, aaa_article1.id, bbb_article2.id]

        # articleのレスポンスのkeyがid,title,updated_at,userであることをテスト
        expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]

        # articleのレスポンスと一生に生成されたuserのkeyがid,name,emailであることをテスト
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

  describe "POST /articles" do
    # subject が叩かれると呼び出されると params をルーティング通りに articles_controller に渡す
    # params の値は let(:params){ {article: attributes_for(:article)} } で生成される
    # 渡す時に article という key に値を渡さないといけない
    subject { post(api_v1_articles_path, params: params) }

    context "適切なパラメータを送信した場合" do
      let(:params) { { article: attributes_for(:article) } }
      # let(:params) do
      #   article(key): attributes_for(:article)
      # end
      let(:current_user) { create(:user) }

      # stub
      # Api::V1::BaseApiController の current_user メソッドが呼び出されたら本来の実装とは異なる後ろの current_user を返す
      # 後ろの current_user が呼び出されたら let(:current_user) { create(:user) } が呼び出され create される
      # 今回は before が使われているので it が走る前に処理が行われる
      # before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }
      before do
        current_user_mock = instance_double(Api::V1::BaseApiController)
        allow(current_user_mock).to receive(:current_user).and_return(current_user)
      end

      it "記事のレコードが作成できる" do
        aggregate_failures do
          # API を叩いた後の Article の current_user の数が1個にかわったことをテスト
          # Article と current_userの紐づけが出来ていることと user_id が current_user の id になっていることを意味している
          expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
          res = response.parsed_body
          # res = JSON.parse(response.body)

          # パラメータを送信した直後とレスポンスの整合を確認するテスト
          expect(res["title"]).to eq params[:article][:title]
          expect(res["body"]).to eq params[:article][:body]

          # httpsステータスが:ok(200)であることをテスト
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context "不適切なパラメータを送信した場合" do
      let(:params) { attributes_for(:article) }
      let(:current_user) { create(:user) }
      # before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }
      before do
        current_user_mock = instance_double(Api::V1::BaseApiController)
        allow(current_user_mock).to receive(:current_user).and_return(current_user)
      end

      it "エラーする" do
        expect { subject }.to raise_error(ActionController::ParameterMissing)
      end
    end
  end

  describe "PATCH /articles/:id" do
    subject { patch(api_v1_article_path(article.id), params: params) }

    let(:params) { { article: attributes_for(:article) } }
    let(:current_user) { create(:user) }
    before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }

    context "ログインユーザーが自身の記事を更新しようとする場合" do
      let(:article) { create(:article, user: current_user) }
      it "レコードが更新できる" do
        expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                              change { article.reload.body }.from(article.body).to(params[:article][:body])
        expect(response).to have_http_status(:ok)
      end
    end

    context "自分が所持していない記事のレコードを更新しようとするとき" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }

      it "更新できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
