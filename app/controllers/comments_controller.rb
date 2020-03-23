class CommentsController < ApplicationController
  before_action :logged_in_user
  before_action :load_post, except: :update
  before_action :load_comment, :correct_user, except: :create

  def create
    @comment = @post.comments.build comment_params
    @comment.user = current_user
    if @comment.save
      if comment_params[:parent_id].present?
        notif = {
          sender: current_user,
          receiver: @comment.parent_user,
          post: @post,
          type_notif: Settings.notification.reply
        }
        NotificationPushService.new(notif).push_notification unless current_user? @comment.parent_user
      else
        notif = {
          sender: current_user,
          receiver: @post.user,
          post: @post,
          type_notif: Settings.notification.comment
        }
        NotificationPushService.new(notif).push_notification unless current_user? @post.user
      end
      respond_to do |format|
        format.html{redirect_to @post}
        format.js
      end
    else
      flash[:danger] = t ".post_comment_fail"
      redirect_back fallback_location: root_path
    end
  end

  def edit; end

  def update
    if @comment.update content: comment_params[:content]
      respond_to do |format|
        format.html{redirect_to @post}
        format.js
      end
    else
      flash.now[:danger] = t ".update_fail"
      redirect_to root_path
    end
  end

  def destroy
    user = @comment.user
    if @comment.destroy
      respond_to do |format|
        format.html{redirect_to user}
        format.js
      end
    else
      flash[:danger] = t ".destroy_failed"
      redirect_to user
    end
  end

  private

  def load_post
    @post = Post.find_by id: params[:post_id]
    return if @post

    flash[:danger] = t ".post_not_found"
    redirect_back fallback_location: root_path
  end

  def load_comment
    @comment = Comment.find_by id: params[:id]
    return if @comment

    flash[:danger] = t ".comment_not_found"
    redirect_back fallback_location: root_path
  end

  def correct_user
    return if current_user? @comment.user

    flash[:danger] = t "access_denied"
    redirect_back fallback_location: root_path
  end

  def comment_params
    params.require(:comment).permit :content, :parent_id
  end
end
