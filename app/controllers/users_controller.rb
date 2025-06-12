class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:search, :update]
  before_action :set_user, only: [:show, :following, :followers, :update]
  before_action :authorize_user, only: [:update]
  
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

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: 'Profile updated successfully.'
    else
      redirect_to user_path(@user), alert: 'Unable to update profile.'
    end
  end

  def following
    @following_users = @user.following.order_by(display_name: :asc)
  end

  def followers
    @follower_users = @user.followers.order_by(display_name: :asc)
  end

  def search
    @query = params[:q]&.strip
    @users = []
    
    if @query.present? && @query.length >= 2
      # Search for users by display name (case insensitive)
      # Exclude the current user from search results
      @users = User.where(
        :display_name => /#{Regexp.escape(@query)}/i
      ).where(
        :id.ne => current_user.id
      ).limit(20).order_by(display_name: :asc)
    elsif @query.present? && @query.length < 2
      @error = "Search term must be at least 2 characters long."
    end
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    redirect_to root_path, alert: 'User not found.'
  end

  def authorize_user
    unless current_user == @user
      redirect_to user_path(@user), alert: 'You are not authorized to perform this action.'
    end
  end

  def user_params
    params.require(:user).permit(:favorite_team)
  end
end