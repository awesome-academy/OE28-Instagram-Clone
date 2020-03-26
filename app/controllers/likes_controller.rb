class LikesController < ApplicationController
  before_action :authenticate_user!, :load_object, only: :index
  before_action :object_exists, :correct_user_like_bookmark, only: %i(create destroy)
  before_action :find_like, only: :destroy

  def index
    @title = t ".title"
    @tips = t ".tips"
    @users = User.likers_to_likeable(@object.id, params[:type])
                 .page(params[:page])
                 .per Settings.user.previews_per_page
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    params[:type_action] = params[:type_action].to_i
    @new_like = current_user.bookmark_likes.build bookmark_like_params
    if @new_like.save
      push_notification
      respond_to do |format|
        format.html{redirect_to @user}
        format.js
      end
    else
      flash[:danger] = t "likes.find_post.not_find_post"
      redirect_to root_url
    end
  end

  def destroy
    if @like.destroy
      respond_to do |format|
        format.html{redirect_to @user}
        format.js
      end
    else
      flash[:danger] = t "likes.find_post.not_find_post"
      redirect_to root_url
    end
  end

  private

  def load_object
    object_class = Object.const_get params[:type]
    @object = object_class.find_by id: params[:id]
    return if @object

    flash[:danger] = t "likes.find_post.not_found"
    redirect_to root_url
  end

  def find_like
    @like = current_user
            .bookmark_likes
            .find_by likeable_id: bookmark_like_params[:likeable_id],
              type_action: bookmark_like_params[:type_action],
              likeable_type: bookmark_like_params[:likeable_type]
    return if @like

    flash[:danger] = t "likes.find_post.not_find_post"
    redirect_to root_url
  end

  def push_notification
    class_name = @object.class.name
    notif = {
      sender: current_user,
      receiver: @object.user,
      post: class_name.eql?(Post.name) ? @object : @object.post,
      type_notif: if class_name.eql?(Post.name)
                    Settings.notification.like
                  else
                    Settings.notification.like_comment
                  end
    }
    NotificationPushService.new(notif).push_notification unless current_user? @object.user
  end
end
