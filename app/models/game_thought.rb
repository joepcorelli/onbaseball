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
  
  belongs_to :user
  has_many :votes, dependent: :destroy
  
  validates :content, presence: true, length: { minimum: 1, maximum: 500 }
  validates :game_id, presence: true
  validates :game_date, presence: true
  
  index({ game_id: 1, created_at: -1 })
  index({ user_id: 1, game_date: -1 })
  
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
end