require "rails_helper"

RSpec.describe User, type: :model do
  describe "正常系" do
    context "必要な情報が揃っている場合" do
      let(:user) { build(:user) }

      it "ユーザー登録できる" do
        expect(user).to be_valid
      end
    end
  end

  describe "異常系" do
    context "名前のみ入力している場合" do
      let(:user) { build(:user, email: nil, password: nil) }

      it "エラーが発生する" do
        expect(user).not_to be_valid
        # expect(user.errors.details[:email][0][:error]).to eq :blank
        # expect(user.errors.details[:password][0][:error]).to eq :blank
        # binding.pry
      end
    end

    context "email がない場合" do
      let(:user) { build(:user, email: nil) }

      it "エラーが発生する" do
        expect(user).not_to be_valid
        # expect(user).to be_valid
        # expect(user.errors.details[:email][0][:error]).to eq :blank
        # binding.pry
      end
    end

    context "password がない場合" do
      let(:user) { build(:user, password: nil) }

      it "エラーが発生する" do
        expect(user).not_to be_valid
        # expect(user.errors.details[:password][0][:error]).to eq :blank
      end
    end
  end
end
