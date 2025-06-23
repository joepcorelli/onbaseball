namespace :game_thoughts do
  desc "Backfill game context for existing thoughts where possible"
  task backfill_context: :environment do
    puts "Starting game context backfill..."
    
    # Find all thoughts without context
    thoughts_without_context = GameThought.where(game_context: 'unknown')
    total_count = thoughts_without_context.count
    
    puts "Found #{total_count} thoughts without context"
    
    processed = 0
    updated = 0
    failed = 0
    
    # Group by game_date for efficient API calls
    thoughts_by_date = thoughts_without_context.group_by(&:game_date)
    
    thoughts_by_date.each do |game_date, thoughts_for_date|
      puts "Processing #{thoughts_for_date.count} thoughts for #{game_date}..."
      
      begin
        # Get all games for this date
        games_data = MlbApiService.games_for_date(game_date)
        games_by_id = games_data.index_by { |game| game['gamePk'].to_s }
        
        thoughts_for_date.each do |thought|
          processed += 1
          
          begin
            game_data = games_by_id[thought.game_id.to_s]
            
            if game_data
              # Try to determine context based on game timing and thought timestamp
              estimated_context = estimate_context_from_timing(thought, game_data)
              
              if estimated_context
                thought.update!(estimated_context)
                updated += 1
                print "✓"
              else
                print "?"
              end
            else
              print "X"
              failed += 1
            end
            
          rescue => e
            print "E"
            failed += 1
            Rails.logger.error "Failed to update thought #{thought.id}: #{e.message}"
          end
          
          # Print progress every 50 thoughts
          if processed % 50 == 0
            puts "\nProgress: #{processed}/#{total_count} (#{updated} updated, #{failed} failed)"
          end
        end
        
        # Rate limit API calls to be respectful
        sleep(1) if thoughts_by_date.keys.count > 1
        
      rescue => e
        puts "\nError processing date #{game_date}: #{e.message}"
        failed += thoughts_for_date.count
      end
    end
    
    puts "\n\nBackfill complete!"
    puts "Total processed: #{processed}"
    puts "Successfully updated: #{updated}"
    puts "Failed: #{failed}"
    puts "Remaining unknown: #{GameThought.where(game_context: 'unknown').count}"
  end
  
  private
  
  def estimate_context_from_timing(thought, game_data)
    game_time = DateTime.parse(game_data['gameDate'])
    thought_time = thought.created_at
    game_status = game_data['status']['statusCode']
    
    # Calculate time difference in hours
    time_diff = (thought_time - game_time) / 1.hour
    
    context = {
      game_status_code: game_status
    }
    
    # Estimate based on timing relative to scheduled game time
    if time_diff < -0.5  # Posted more than 30 minutes before game
      context[:game_context] = 'before'
    elsif time_diff > 4  # Posted more than 4 hours after scheduled start
      context[:game_context] = 'after'
    elsif game_status == 'F'  # Game is final, check if thought was during typical game duration
      if time_diff >= 0 && time_diff <= 4
        context[:game_context] = 'during'
      else
        context[:game_context] = 'after'
      end
    else
      # Can't reliably determine context
      return nil
    end
    
    context
  end
end