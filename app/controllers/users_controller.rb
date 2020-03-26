class UsersController < ApplicationController
  before_action :authenticate_user!, :load_user
  before_action :correct_user, only: %i(edit update)

  def show; end

  def edit; end

  def update
    params[:user][:gender] = params[:user][:gender].to_i
    params[:user][:status] = params[:user][:status].to_i
    if @user.update_user user_params_update
      flash[:success] = t ".update_succeed"
      redirect_to @user
    else
      flash.now[:danger] = t ".update_failed"
      render :edit
    end
  end

  private
  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "users.load_user.not_find_user"
    redirect_to root_path
  end

  def correct_user
    return if current_user? @user

    flash[:danger] = t "users.correct_user.not_allow"
    redirect_to root_url
  end
end
