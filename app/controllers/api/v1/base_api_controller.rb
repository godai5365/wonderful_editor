class Api::V1::BaseApiController < ApplicationController
  # def current_user
  #   @current_user = User.first
  # end
  # 以下 2/15 追記
  alias_method :current_user, :current_api_v1_user
  alias_method :authenticate_user!, :authenticate_api_v1_user!
  alias_method :user_signed_in?, :api_v1_user_signed_in?
end
