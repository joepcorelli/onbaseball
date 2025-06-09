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
end