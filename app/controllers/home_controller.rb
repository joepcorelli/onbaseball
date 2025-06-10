class HomeController < ApplicationController
  # No authentication required for viewing games

  def index
    @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    games = MlbApiService.games_for_date(@selected_date)
    
    # Sort games according to your requirements
    @games = sort_games_by_priority(games)
    
    if user_signed_in?
      # Get user's existing game thoughts for the selected date
      @user_game_thoughts = current_user.game_thoughts.where(game_date: @selected_date)
                                       .group_by(&:game_id)
    end
  end
  
  private
  
  def sort_games_by_priority(games)
    # Separate games by status
    in_progress = []
    upcoming = []
    finished = []
    
    games.each do |game|
      case game['status']['statusCode']
      when 'I' # In progress
        in_progress << game
      when 'F' # Finished
        finished << game
      else # Upcoming (includes 'S' for scheduled, 'P' for pre-game, etc.)
        upcoming << game
      end
    end
    
    # Sort in-progress games by inning (later innings first)
    in_progress.sort! do |a, b|
      inning_a = a.dig('linescore', 'currentInning') || 0
      inning_b = b.dig('linescore', 'currentInning') || 0
      inning_b <=> inning_a # Reverse order (later innings first)
    end
    
    # Sort upcoming games by start time (soonest first)
    upcoming.sort! do |a, b|
      time_a = DateTime.parse(a['gameDate'])
      time_b = DateTime.parse(b['gameDate'])
      time_a <=> time_b
    end
    
    # Finished games can stay in their original order, or sort by game time if preferred
    finished.sort! do |a, b|
      time_a = DateTime.parse(a['gameDate'])
      time_b = DateTime.parse(b['gameDate'])
      time_a <=> time_b
    end
    
    # Combine in the desired order: in_progress, upcoming, finished
    in_progress + upcoming + finished
  end
end