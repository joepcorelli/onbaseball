class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  
  def context_stats
    @total_thoughts = GameThought.count
    @thoughts_by_context = GameThought.group(:game_context).count
    @recent_unknown = GameThought.where(game_context: 'unknown')
                                .order_by(created_at: :desc)
                                .limit(10)
  end
  
  private
  
  def ensure_admin
    # Add your admin check logic here
    # For now, just check if it's you
    redirect_to root_path unless current_user.email == 'your-admin-email@example.com'
  end
end