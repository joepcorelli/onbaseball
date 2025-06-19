class GamesController < ApplicationController
  # No authentication required for viewing game details
  
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
                                   .order_by(created_at: :desc)
    
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

    # --- New: Fetch inning transitions and game start/end times ---
    @inning_transitions = []
    @game_start = DateTime.parse(@game['gameDate']).in_time_zone rescue nil
    @game_end = nil
    if @game['status']['statusCode'] == 'F' && @game['linescore'] && @game['linescore']['endTime']
      @game_end = DateTime.parse(@game['linescore']['endTime']).in_time_zone rescue nil
    end
    # Fallback: If no endTime, use last play's time
    if @game_end.nil?
      begin
        pbp = MlbApiService.play_by_play(@game_id)
        if pbp && pbp['liveData'] && pbp['liveData']['plays'] && pbp['liveData']['plays']['allPlays']&.any?
          last_play = pbp['liveData']['plays']['allPlays'].last
          @game_end = Time.parse(last_play['about']['endTime']) rescue nil
        end
      rescue
        @game_end = nil
      end
    end
    @inning_transitions = MlbApiService.inning_transitions(@game_id)
  end
end