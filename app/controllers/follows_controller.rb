class FollowsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  
  def create
    if current_user.follow(@user)
      # Create notification for the followed user
      @user.received_notifications.create!(
        type: 'follow',
        actor: current_user,
        message: "#{current_user.display_name} started following you"
      )
      redirect_back(fallback_location: user_path(@user), notice: "You are now following #{@user.display_name}")
    else
      redirect_back(fallback_location: user_path(@user), alert: "Unable to follow user")
    end
  end
  
  def destroy
    current_user.unfollow(@user)
    redirect_back(fallback_location: user_path(@user), notice: "You are no longer following #{@user.display_name}")
  end
  
  private
  
  def set_user
    @user = User.find(params[:user_id])
  rescue Mongoid::Errors::DocumentNotFound
    redirect_to root_path, alert: 'User not found.'
  end
end