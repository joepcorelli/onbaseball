class UsersController < ApplicationController
  before_action :set_user, only: [:show]
  
  def show
    @user = User.find(params[:id])

    # Get all game thoughts for this user, ordered by most recent first
    @game_thoughts = @user.game_thoughts.order(created_at: :desc)

    # Get some stats for the profile
    @total_thoughts = @game_thoughts.count
    @total_likes = @game_thoughts.sum(:likes_count)
    @member_since = @user.created_at

    # Get all game thoughts by this user, ordered by most recent first
    @user_thoughts = @user.game_thoughts.order_by(created_at: :desc).limit(50)
    
    # Group thoughts by game for better display
    @thoughts_by_game = @user_thoughts.group_by(&:game_id)
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    redirect_to root_path, alert: 'User not found.'
  end
end