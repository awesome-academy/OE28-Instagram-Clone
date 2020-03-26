class Admin::UsersController < ApplicationController
  before_action :authenticate_user!, :is_admin
  before_action :load_user, except: %i(index new create)
  before_action :search, :sort, only: :index
  
  def index
    @users ||= User.order_by_created_at
                   .page(params[:page])
                   .per Settings.user.previews_per_page
    @user_hash = {
      user: User.new,
      users: @users,
      title: t(".users"),
      page: params[:page],
      type: params[:type],
      sort_value: params[:sort_value],
      text_search: params[:text_search]
    }
    @title = t ".users"
    respond_to :html, :js
  end

  def create
    @user = User.new user_params
    if @user.save
      flash[:success] = t ".signup_success"
    else
      flash[:danger] = t ".signup_failed"
    end
    redirect_back fallback_location: root_path
  end

  def update
    params[:user][:gender] = params[:user][:gender].to_i
    params[:user][:status] = params[:user][:status].to_i
    if @user.update_user user_params_update
      respond_to :js
    else
      @messages = t ".update_failed"
      respond_to do |format|
        format.html{redirect_back fallback_location: root_path}
        format.js{flash.now[:notice] = @messages}
      end
    end
  end

  def destroy
    if @user.destroy
      respond_to :js
    else
      @messages = t ".error_destroy"
      respond_to do |format|
        format.html{redirect_to root_path}
        format.js{flash.now[:notice] = @messages}
      end
    end
  end

  private
  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "users.load_user.not_find_user"
    redirect_to root_path
  end

  def sort
    return unless params[:type].eql? Settings.sort_user.type

    users_search = User.search_by_name_username(params[:text_search])
    @users = case params[:sort_value].to_i
             when Settings.sort_user.updated_at
               users_search.order_by_updated_at
                           .page(params[:page]).per Settings.user.previews_per_page
             when Settings.sort_user.name
               users_search.order_by_name
                           .page(params[:page]).per Settings.user.previews_per_page
             when Settings.sort_user.username
               users_search.order_by_username
                           .page(params[:page]).per Settings.user.previews_per_page
             else
               users_search.order_by_created_at
                           .page(params[:page]).per Settings.user.previews_per_page
             end
  end

  def search
    return unless params[:type].eql? Settings.search.type

    @users = User.search_by_name_username(params[:text_search])
                 .order_by_created_at
                 .page(params[:page]).per Settings.user.previews_per_page
  end
end
