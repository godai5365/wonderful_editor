module Api::V1
  # base_api_controller を継承
  class Articles::DraftsController < BaseApiController
    before_action :authenticate_user!, only: [:index, :show]

    def index
      articles = current_user.articles.draft.order(updated_at: :desc)
      render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
    end

    def show
      article = current_user.articles.draft.find(params[:id])
      render json: article, serializer: Api::V1::ArticleSerializer
    end
  end
end
