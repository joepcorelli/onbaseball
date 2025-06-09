class GamesController < ApplicationController
  def show
    @game_id = params[:id]
    @game_date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    
    # Get game data from MLB API
    games = MlbApiService.games_for_date(@game_date)
    @game = games.find { |g| g['gamePk'].to_s == @game_id }
    
    if @game.nil?
      redirect_to root_path, alert: 'Game not found.'
      return
    end
    
    # Get all thoughts for this game, ordered by creation time
    @all_game_thoughts = GameThought.where(game_id: @game_id, game_date: @game_date)
                                   .includes(:user)
                                   .order_by(created_at: :asc)
    
    # Get current user's thoughts for this game (if logged in)
    if user_signed_in?
      @user_thoughts = @all_game_thoughts.where(user: current_user)
      @other_thoughts = @all_game_thoughts.where(:user.ne => current_user)
    else
      @user_thoughts = []
      @other_thoughts = @all_game_thoughts
    end
    
    # Prepare new thought form
    @new_game_thought = GameThought.new if user_signed_in?
  end
end