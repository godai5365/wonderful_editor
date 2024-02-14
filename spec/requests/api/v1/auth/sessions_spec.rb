require "rails_helper"

RSpec.describe "Api::V1::Auth::Sessions" do
  describe "POST api/v1/auth/sign_in" do
    subject { post(api_v1_user_session_path, params: params) }

    context "正しい情報を送信したユーザーがログインしようとする場合" do
      # ログイン用にユーザーを作成する
      let(:user) { create(:user) }
      let(:params) { attributes_for(:user, email: user.email, password: user.password) }

      it "ログインできる" do
        subject
        header = response

        # ログインする時に必要な情報として以下の3つが挙げられる
        # "access-token","uid","client"が存在することを確認するテスト
        expect(header["access-token"]).to be_present
        expect(header["uid"]).to be_present
        expect(header["client"]).to be_present

        expect(response).to have_http_status(:ok)
      end
    end

    context "emailが間違っている場合" do
      let(:user) { create(:user) }
      let(:params) { attributes_for(:user, email: "foo", password: user.password) }

      it "ログインできない" do
        subject
        res = response.parsed_body
        header = response
        aggregate_failures do
          # コンソールで response.parsed_body を打ち込むと
          # => {"success"=>false, "errors"=>["Invalid login credentials. Please try again."]}
          # と表示されたので errors が "Invalid login credentials. Please try again." を include(〜を含む) していることをテストした
          expect(res["errors"]).to include "Invalid login credentials. Please try again."

          # response の中に下記の3つが含まれていないので be_blank でテストした
          expect(header["access-token"]).to be_blank
          expect(header["uid"]).to be_blank
          expect(header["client"]).to be_blank

          # subject を打つと401と表示されたので同じ意味である :unauthorized を使いステータスをテストした
          expect(response).to have_http_status(:unauthorized) # 401 でも可
        end
      end
    end

    context "passwordが間違っている場合" do
      let(:user) { create(:user) }
      let(:params) { attributes_for(:user, email: user.email, password: "password") }

      it "ログインできない" do
        subject
        res = response.parsed_body
        header = response
        aggregate_failures do
          # email の時と同様のため省略
          expect(res["errors"]).to include "Invalid login credentials. Please try again."
          expect(header["access-token"]).to be_blank
          expect(header["uid"]).to be_blank
          expect(header["client"]).to be_blank
          expect(response).to have_http_status(:unauthorized) # 401 でも可
        end
      end
    end
  end

  describe "DELETE api/v1/auth/sign_out" do
    subject { delete(destroy_api_v1_user_session_path, headers: headers) }

    context "正しい情報を送信したユーザーがログアウトしようとする場合" do
      let(:user) { create(:user) }
      let!(:headers) { user.create_new_auth_token }

      it "ログアウトできる" do
        expect { subject }.to change { user.reload.tokens }.from(be_present).to(be_blank)
        expect(response).to have_http_status(:ok)
        # expect(user.reload.tokens).to be_blank
      end
    end

    context "誤った情報を送信したユーザーがログアウトしようとする場合" do
      let(:user) { create(:user) }
      let!(:headers) { { "access-token" => "", "client" => "", "uid" => "" } }

      it "ログアウトできない" do
        subject
        expect(response).to have_http_status(:not_found)
        res = response.parsed_body
        expect(res["errors"]).to include "User was not found or was not logged in."
        expect(res["success"]).to be false
      end
    end
  end
end
