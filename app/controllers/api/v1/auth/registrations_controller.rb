class Api::V1::Auth::RegistrationsController < DeviseTokenAuth::RegistrationsController
  private

    # Userを登録する時にnameも登録させたいため、strong_parameterにnameも追加しています。
    def sign_up_params
      params.permit(:name, :email, :password, :password_confirmation)
    end

    def account_update_params
      params.permit(:name, :email)
    end
end
