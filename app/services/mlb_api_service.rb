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

  # Fetch play-by-play data for a game
  def self.play_by_play(game_pk)
    response = get("/game/#{game_pk}/feed/live")
    response.success? ? response.parsed_response : nil
  end

  # Extract inning/half-inning transitions with timestamps
  # Returns an array of hashes: [{ label: 'Top 1st', start: Time, end: Time }, ...]
  def self.inning_transitions(game_pk)
    data = play_by_play(game_pk)
    return [] unless data && data['liveData'] && data['liveData']['plays'] && data['liveData']['plays']['allPlays']

    plays = data['liveData']['plays']['allPlays']
    transitions = []
    current_label = nil
    current_start = nil
    last_inning = nil
    last_half = nil

    # Helper to build label
    label_for = ->(inning, half) {
      case half
      when 'top' then "Top #{ordinal(inning)}"
      when 'bottom' then "Bottom #{ordinal(inning)}"
      else nil
      end
    }

    # Helper for ordinal
    def self.ordinal(n)
      n = n.to_i
      if (11..13).include?(n % 100)
        "#{n}th"
      else
        case n % 10
        when 1; "#{n}st"
        when 2; "#{n}nd"
        when 3; "#{n}rd"
        else    "#{n}th"
        end
      end
    end

    # Find all transitions (top, mid, bottom, end) with timestamps
    # We'll use play events where inning/half changes
    plays.each_with_index do |play, idx|
      inning = play['about']['inning']
      half = play['about']['halfInning'] # 'top' or 'bottom'
      play_time = Time.parse(play['about']['startTime']) rescue nil
      next unless inning && half && play_time

      if last_inning.nil? || last_half.nil?
        # First play of the game
        current_label = label_for.call(inning, half)
        current_start = play_time
        last_inning = inning
        last_half = half
        next
      end

      if inning != last_inning || half != last_half
        # Transition: close previous segment
        transitions << { label: label_for.call(last_inning, last_half), start: current_start, end: play_time }
        # Add mid/end label for previous inning/half
        if half == 'bottom' && last_half == 'top'
          transitions << { label: "Mid #{ordinal(last_inning)}", start: play_time, end: nil }
        elsif half == 'top' && last_half == 'bottom'
          transitions << { label: "End #{ordinal(last_inning)}", start: play_time, end: nil }
        end
        # Start new segment
        current_label = label_for.call(inning, half)
        current_start = play_time
        last_inning = inning
        last_half = half
      end
    end
    # Add the last segment
    if current_label && current_start
      transitions << { label: current_label, start: current_start, end: nil }
    end
    transitions
  end
end