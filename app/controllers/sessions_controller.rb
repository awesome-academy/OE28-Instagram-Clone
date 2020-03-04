class SessionsController < ApplicationController
  def new
    redirect_to current_user if user_signed_in?
  end

  def create
    user = User.find_by email: params[:session][:email]
    if user&.authenticate(params[:session][:password])
      log_in_if_activated user
    else
      flash.now[:danger] = t ".invalid_message"
      render :new
    end
  end

  def destroy
    log_out if user_signed_in?
    redirect_to login_path
  end
end
