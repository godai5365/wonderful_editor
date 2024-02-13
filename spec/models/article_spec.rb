# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_articles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Article do
  describe "正常系" do
    context "タイトルと本文が入力されている" do
      let(:article) { build(:article) }

      it "記事が作成できる" do
        expect(article).to be_valid
      end
    end
  end
end
