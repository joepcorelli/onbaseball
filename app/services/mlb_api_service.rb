class MlbApiService
  include HTTParty
  base_uri 'https://statsapi.mlb.com/api/v1'
  
  def self.games_for_date(date)
    formatted_date = date.strftime('%Y-%m-%d')
    response = get("/schedule?sportId=1&date=#{formatted_date}&hydrate=team,linescore,pitchingProbables")
    
    if response.success?
      response.parsed_response.dig('dates', 0, 'games') || []
    else
      []
    end
  end
  
  # NEW METHOD: Determine game context based on current game state
  def self.determine_game_context(game_data)
    status_code = game_data['status']['statusCode']
    
    context = {
      game_context: nil,
      inning: nil,
      inning_half: nil,
      game_status_code: status_code
    }
    
    case status_code
    when 'S', 'P', 'PW', 'PRE'  # Scheduled, Pre-Game, Preview, Pre-Game Warmup
      context[:game_context] = 'before'
    when 'I', 'IW'  # In Progress, In Progress Warmup
      context[:game_context] = 'during'
      # Extract inning information if available
      if game_data.dig('linescore', 'currentInning')
        context[:inning] = game_data.dig('linescore', 'currentInning')
        context[:inning_half] = game_data.dig('linescore', 'inningHalf')&.downcase
      end
    when 'F', 'FR', 'FT', 'CO', 'CW'  # Final, Final (Completed Early), Final (Tie), Called Off, Called (Weather)
      context[:game_context] = 'after'
    else
      # Default to 'before' for unknown statuses
      context[:game_context] = 'before'
    end
    
    context
  end
end