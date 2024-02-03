require "rails_helper"

RSpec.describe Article, type: :model do
  describe "正常系" do
    context "タイトルと本文が入力されている" do
      let(:article) { build(:article) }

      it "記事が作成できる" do
        expect(article).to be_valid
      end
    end
  end
end
