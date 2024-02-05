class Api::V1::ArticlePreviewSerializer < ActiveModel::Serializer
  # title, updtated_atを追加、含めたくないcreated_atは書かない,出力したいカラムを指定
  attributes :id, :title, :updated_at # 追加
  # アソシエーションを指定
  belongs_to :user, serializer: Api::V1::UserSerializer # 追加
end
