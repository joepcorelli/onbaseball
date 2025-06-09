class UsersController < ApplicationController
  before_action :set_user, only: [:show]
  
  def show
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