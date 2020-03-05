class UsersController < ApplicationController
  before_action :get_user, except: %i(new create)

  def new
    @user = User.new
  end

  def show; end

  def create
    @user = User.new user_params
    if @user.save
      flash[:success] = t ".signup_success"
      redirect_to @user
    else
      flash.now[:danger] = t ".signup_failed"
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit :email, :name, :username,
                                 :password, :password_confirmation
  end

  def get_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t ".not_find_user"
    redirect_to root_path
  end
end
