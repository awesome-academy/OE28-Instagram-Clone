class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(new create)
  before_action :get_user, except: %i(new create)
  before_action :correct_user, only: %i(edit update)

  def new
    @user = User.new
  end

  def show; end

  def create
    @user = User.new user_params
    if @user.save
      log_in @user
      flash[:success] = t ".signup_success"
      redirect_to @user
    else
      flash.now[:danger] = t ".signup_failed"
      render :new
    end
  end

  def edit; end

  def update
    params[:user][:gender] = params[:user][:gender].blank? ? nil:
      params[:user][:gender].to_i
    if @user.update user_params_update
      flash[:success] = t ".update_succeed"
      redirect_to @user
    else
      flash.now[:danger] = t ".update_failed"
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit :email, :name, :username,
                                 :password, :password_confirmation
  end
  
  def user_params_update
    if params[:user][:avatar_image].blank?
      params.require(:user).permit :email, :name, :username, :website, :bio,
                                   :phone, :gender
    else
      params.require(:user).permit :email, :name, :username, :website, :bio,
                                   :phone, :gender, :avatar_image
    end
  end

  def correct_user
    return if current_user? @user

    flash[:danger] = t "users.correct_user.not_allow"
    redirect_to root_url
  end

  def get_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "users.get_user.not_find_user"
    redirect_to root_path
  end
end
