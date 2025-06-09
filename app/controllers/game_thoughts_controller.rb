class GameThoughtsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_game_thought, only: [:show, :destroy, :like, :dislike]
  
  def create
    @game_thought = current_user.game_thoughts.build(game_thought_params)
    
    if @game_thought.save
      redirect_to root_path(date: @game_thought.game_date), 
                  notice: 'Your thought was successfully saved!'
    else
      redirect_to root_path(date: @game_thought.game_date), 
                  alert: 'There was an error saving your thought. Please try again.'
    end
  end
  
  def show
    # This will show a specific game thought (for future features)
    # For now, just redirect to the game detail page
    redirect_to game_path(@game_thought.game_id, date: @game_thought.game_date)
  end
  
  def destroy
    game_date = @game_thought.game_date
    @game_thought.destroy
    redirect_to root_path(date: game_date), notice: 'Your thought was deleted.'
  end
  
  def like
    handle_vote('like')
  end

  def dislike
    handle_vote('dislike')
  end
  
  private
  
  def set_game_thought
    @game_thought = GameThought.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    redirect_to root_path, alert: 'Thought not found.'
  end
  
  def game_thought_params
    params.require(:game_thought).permit(:content, :game_id, :game_date, :team_home, :team_away)
  end
  
  def handle_vote(vote_type)
    existing_vote = @game_thought.votes.where(user: current_user).first
    
    if existing_vote
      if existing_vote.vote_type == vote_type
        # User is clicking the same vote type - remove the vote (toggle off)
        existing_vote.destroy
      else
        # User is switching from like to dislike or vice versa
        existing_vote.update!(vote_type: vote_type)
      end
    else
      # User hasn't voted yet - create new vote
      @game_thought.votes.create!(user: current_user, vote_type: vote_type)
    end
    
    # Update the cached vote counts
    @game_thought.update_vote_counts!
    
    redirect_back(fallback_location: root_path)
  end
end