module Api::V1
  # base_api_controller を継承
  class ArticlesController < BaseApiController
    def index
      articles = Article.order(updated_at: :desc)
      render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
    end

    def show
      article = Article.find(params[:id])
      render json: article, each_serializer: Api::V1::ArticleSerializer
    end

    def create
      # article_paramsに送信されたパラメータを取得する
      # そのパラメータとログインユーザーに紐づいた記事を作る
      # articlesは関連するレコードを取得するために記述
      article = current_user.articles.create!(article_params)
      render json: article, serializer: Api::V1::ArticleSerializer
    end

    private

      # Strong Parameters
      # .requireメソッドがデータのオブジェクト名を定め
      # .permitメソッドで変更を加えられる（保存の処理ができる）キーを指定
      def article_params
        params.require(:article).permit(:title, :body)
      end
  end
end
