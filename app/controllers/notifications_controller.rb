class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.received_notifications.ordered.page(params[:page])
    current_user.mark_notifications_as_read
  end

  def mark_as_read
    @notification = current_user.received_notifications.find(params[:id])
    @notification.update(read: true)
    head :ok
  end
end 