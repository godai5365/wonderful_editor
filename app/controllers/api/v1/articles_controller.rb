module Api::V1
  # base_api_controller を継承
  class ArticlesController < BaseApiController
    before_action :authenticate_user!, only: [:create, :update, :destroy] # 2/15 追記

    def index
      articles = Article.published.order(updated_at: :desc)
      render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
    end

    def show
      article = Article.published.find(params[:id])
      render json: article, serializer: Api::V1::ArticleSerializer
    end

    def create
      # 送信されたパラメータを params で取得する
      # そのパラメータとログインユーザーに紐づいた記事を作る
      # articlesは関連するレコードを取得するために記述
      article = current_user.articles.create!(article_params)
      render json: article, serializer: Api::V1::ArticleSerializer
    end

    def update
      article = current_user.articles.find(params[:id])
      article.update!(article_params)
      render json: article, serializer: Api::V1::ArticleSerializer
    end

    def destroy
      article = current_user.articles.find(params[:id])
      article.destroy!
    end

    private

      # Strong Parameters
      # .requireメソッドがデータのオブジェクト名を定め
      # .permitメソッドで変更を加えられる（保存の処理ができる）キーを指定
      def article_params
        params.require(:article).permit(:title, :body, :status)
      end
  end
end
