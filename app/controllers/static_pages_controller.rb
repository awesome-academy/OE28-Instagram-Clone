class StaticPagesController < ApplicationController
  before_action :authenticate_user!

  def index
    @post = Post.new
    @feed_items = Post.feed(current_user.id)
                      .order_by_created_at
                      .page(params[:page])
                      .per Settings.feed_items_per_page
    @page = params[:page]
    respond_to do |format|
      format.html
      format.js
    end
  end

  private
  def log_in_user
    return if user_signed_in?

    flash[:danger] = t "login_first"
    redirect_to login_path
  end

end
