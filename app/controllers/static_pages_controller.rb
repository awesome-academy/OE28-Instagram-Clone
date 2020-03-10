class StaticPagesController < ApplicationController
  before_action :log_in_user

  def index
    @post = Post.new
    @feed_items = Post.feed(current_user.id)
                      .order_by_created_at
                      .page(params[:page])
                      .per Settings.feed_items_per_page
  end

  private
  def log_in_user
    return if user_signed_in?

    flash[:danger] = t "login_first"
    redirect_to login_path
  end
end
