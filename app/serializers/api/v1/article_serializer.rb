class Api::V1::ArticleSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :updated_at # 追加
  belongs_to :user, serializer: Api::V1::UserSerializer # 追加
end
