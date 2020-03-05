class SessionsController < ApplicationController
  def new
    redirect_to current_user if user_signed_in?
  end

  def create
    email_username = params[:session][:email_username]
    user = if email? email_username
             User.find_by email: email_username
           else
             User.find_by username: email_username
           end
    
    if user&.authenticate(params[:session][:password])
      log_in user
      redirect_to user
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
