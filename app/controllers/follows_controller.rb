class FollowsController < ApplicationController
  before_action :load_user, :authenticate_user!

  def following
    @title = t ".title"
    @users = @user.following
                  .page(params[:page])
                  .per Settings.user.previews_per_page
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  def followers
    @title = t ".title"
    @users = @user.followers
                  .page(params[:page])
                  .per Settings.user.previews_per_page
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  private
  def load_user
    @user = User.find params[:id]
    return if @user

    flash[:danger] = t "follow.find_user.not_find_user"
    redirect_to root_url
  end
end
