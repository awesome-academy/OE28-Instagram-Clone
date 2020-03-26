class NotificationsController < ApplicationController
  before_action :authenticate_user!, :load_notification, only: %i(update destroy)
  before_action :update_all_to_read, only: :update

  def index
    @notifications = current_user.passive_notifications
                                 .send(params[:type])
                                 .order_by_created_at
                                 .page(params[:page])
                                 .per Settings.user.previews_per_page
    @page = params[:page]
    respond_to do |format|
      format.html{redirect_to current_user}
      format.js
    end
  end

  def update
    @messages = t ".error_update" unless notification_params[:status].eql?(Settings.notification.read_s) ? @notif.unread! : @notif.read!

    @type_action = Settings.notification.update
    @update_status = notification_params[:status]
    respond_to :js
  end

  def destroy
    @messages = t ".error_destroy" unless @notif.destroy
    @type_action = Settings.notification.delete
    respond_to do |format|
      format.html{redirect_to current_user}
      format.js{render "notifications/update"}
    end
  end

  private

  def load_notification
    @notif = Notification.find_by id: params[:id]
    return if @notif

    @messages = t ".error_update"
    respond_to do |format|
      format.html{redirect_to current_user}
      format.js{render "notifications/update"}
    end
  end

  def update_all_to_read
    return unless params[:update_all]

    @messages = t ".update_all_failed" unless Notification.update_all_to_read current_user
    @notifications = current_user.passive_notifications
                                 .order_by_created_at
                                 .page(params[:page])
                                 .per Settings.user.previews_per_page
    respond_to do |format|
      format.html{redirect_to current_user}
      format.js{render "notifications/update_all"}
    end
  end

  def notification_params
    params.require(:notification).permit :status
  end
end
