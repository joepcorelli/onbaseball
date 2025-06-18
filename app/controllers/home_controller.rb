class HomeController < ApplicationController
  # No authentication required for viewing games

  def index
    @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    games = MlbApiService.games_for_date(@selected_date)
    
    favorite_team = user_signed_in? ? current_user.favorite_team : nil
    # Sort games according to your requirements, prioritizing favorite team if present
    @games = sort_games_by_priority(games, favorite_team)
    
    if user_signed_in?
      # Get user's existing game thoughts for the selected date
      @user_game_thoughts = current_user.game_thoughts.where(game_date: @selected_date)
                                       .group_by(&:game_id)
    end
  end
  
  private
  
  def sort_games_by_priority(games, favorite_team = nil)
    # If favorite_team is present, find its game
    favorite_game = nil
    if favorite_team.present?
      favorite_game = games.find do |game|
        [game.dig('teams', 'home', 'team', 'name'), game.dig('teams', 'away', 'team', 'name')].include?(favorite_team)
      end
    end

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
    ordered_games = in_progress + upcoming + finished

    # If favorite_game is present, move it to the top
    if favorite_game
      ordered_games.delete(favorite_game)
      ordered_games.unshift(favorite_game)
    end
    ordered_games
  end
end