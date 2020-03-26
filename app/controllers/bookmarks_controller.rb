class BookmarksController < ApplicationController
  before_action :authenticate_user!, :load_user, :correct_user, only: :index
  before_action :object_exists, :correct_user_like_bookmark, only: %i(create destroy)
  before_action :find_bookmark, only: :destroy

  def index
    @title = t ".title"
    @posts = Post.bookmarking_by_user(@current_user.id).order_by_created_at
                 .page(params[:page])
                 .per Settings.user.previews_per_page
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    params[:type_action] = params[:type_action].to_i
    @new_bookmark = current_user.bookmark_likes.build bookmark_like_params
    if @new_bookmark.save
      respond_to do |format|
        format.html{redirect_to @user}
        format.js
      end
    else
      flash[:danger] = t "bookmarks.find_user.not_find_user"
      redirect_to root_url
    end
  end

  def destroy
    if @bookmark.destroy
      respond_to do |format|
        format.html{redirect_to @user}
        format.js
      end
    else
      flash[:danger] = t "bookmarks.find_user.not_find_user"
      redirect_to root_url
    end
  end

  private

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "bookmarks.find_user.not_find_user"
    redirect_to root_url
  end

  def correct_user
    return if current_user? @user

    flash[:danger] = t "access_denied"
    redirect_back fallback_location: root_path
  end

  def find_bookmark
    @bookmark = current_user
                .bookmark_likes
                .find_by likeable_id: bookmark_like_params[:likeable_id],
                  type_action: bookmark_like_params[:type_action],
                  likeable_type: bookmark_like_params[:likeable_type]
    return if @bookmark

    flash[:danger] = t "bookmarks.find_user.not_find_user"
    redirect_to root_url
  end
end
