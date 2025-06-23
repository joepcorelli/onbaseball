class GameThought
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :game_id, type: String
  field :content, type: String
  field :game_date, type: Date
  field :team_home, type: String
  field :team_away, type: String
  field :likes_count, type: Integer, default: 0
  field :dislikes_count, type: Integer, default: 0
  
  # Game context fields
  field :game_context, type: String, default: 'unknown'
  field :inning, type: Integer, default: nil
  field :inning_half, type: String, default: nil
  field :game_status_code, type: String, default: 'UNKNOWN'
  
  belongs_to :user
  has_many :votes, dependent: :destroy
  
  validates :content, presence: true, length: { minimum: 1, maximum: 500 }
  validates :game_id, presence: true
  validates :game_date, presence: true
  validates :game_context, presence: true, inclusion: { 
    in: ['before', 'during', 'after', 'unknown'],
    message: "must be before, during, after, or unknown"
  }
  
  index({ game_id: 1, created_at: -1 })
  index({ user_id: 1, game_date: -1 })
  index({ game_context: 1 })
  
  # Method to get user's vote for this thought
  def user_vote(user)
    return nil unless user
    votes.where(user: user).first
  end
  
  # Method to check if user has liked this thought
  def liked_by?(user)
    return false unless user
    user_vote(user)&.vote_type == 'like'
  end
  
  # Method to check if user has disliked this thought
  def disliked_by?(user)
    return false unless user
    user_vote(user)&.vote_type == 'dislike'
  end
  
  # Method to update vote counts based on actual votes
  def update_vote_counts!
    self.likes_count = votes.where(vote_type: 'like').count
    self.dislikes_count = votes.where(vote_type: 'dislike').count
    save!
  end
  
  # Helper methods for displaying context
  def context_display
    case game_context
    when 'before'
      'Before game'
    when 'after'
      'After game'
    when 'during'
      if inning && inning_half
        "#{inning_half.capitalize} #{inning.ordinalize}"
      else
        'During game'
      end
    when 'unknown'
      '' # Don't show anything for unknown context
    end
  end
  
  def posted_during_game?
    game_context == 'during'
  end
  
  def has_context?
    game_context != 'unknown'
  end
end