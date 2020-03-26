class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_post, except: %i(update destroy)
  before_action :load_comment, :correct_user, except: :create
  before_action :correct_private_user, only: :create

  def create
    @comment = @post.comments.build comment_params
    @comment.user = current_user
    if @comment.save
      if comment_params[:parent_id].present?
        push_notification @comment.parent_user, Settings.notification.reply
      else
        push_notification @post.user, Settings.notification.comment
      end
      push_mention_notification
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
    if @comment.destroy
      respond_to do |format|
        format.html{redirect_to @comment.user}
        format.js
      end
    else
      flash[:danger] = t ".destroy_failed"
      redirect_to @comment.user
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

  def push_notification receiver, type
    return if current_user? receiver

    notif = {
      sender: current_user,
      receiver: receiver,
      post: @post,
      type_notif: type
    }
    NotificationPushService.new(notif).push_notification
  end

  def push_mention_notification
    @comment.mentions.each do |user|
      push_notification user, Settings.notification.mention
    end
  end

  def correct_private_user
    relationship = Relationship.find_by followed_id: @post.user.id,
                                        follower_id: current_user.id
    return if current_user?(@post.user) || @post.user.public_mode? ||
              (relationship.present? && relationship.accept?)

    respond_to do |format|
      @message_error = t "incorrect_user"
      format.html
      format.js{render "shared/incorrect_user"}
    end
  end
end
