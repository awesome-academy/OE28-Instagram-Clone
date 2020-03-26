class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_action :user_exist, :email_exist

  def facebook
    facebook_info = request.env["omniauth.auth"].info
    @user = User.new name: facebook_info.name,
      email: facebook_info.email,
      uid: request.env["omniauth.auth"].uid
    render "users/registrations/new"
  end

  private

  def user_exist
    user = User.find_by uid: request.env["omniauth.auth"].uid
    return unless user

    sign_in user
    redirect_to root_path
  end

  def email_exist
    user = User.find_by email: request.env["omniauth.auth"].info.email
    return unless user

    flash[:danger] = t ".email_taken"
    redirect_to new_user_session_path
  end
end
