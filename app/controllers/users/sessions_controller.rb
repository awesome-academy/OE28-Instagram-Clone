class Users::SessionsController < Devise::SessionsController
  include Devise::Controllers::Rememberable
  before_action :configure_sign_in_params, :load_user, only: [:create]

  def create
    if @user&.valid_password?(params[:session][:password])
      sign_in @user
      params[:session][:remember_me] == "1" ? remember_me(@user) : forget_me(@user)
      redirect_to root_path
    else
      flash.now[:danger] = t ".invalid_message"
      render :new
    end
  end

  protected

  def configure_sign_in_params
    devise_parameter_sanitizer.permit :sign_in,
                                      keys: [:email_username, :password]
  end

  private

  def load_user
    email_username = params[:session][:email_username]
    @user = if email? email_username
              User.find_by email: email_username
            else
              User.find_by username: email_username
            end
  end
end
