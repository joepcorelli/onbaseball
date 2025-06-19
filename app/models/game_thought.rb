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
  
  # Returns the context label for this thought
  # Params:
  # - game_start: Time (scheduled start)
  # - game_end: Time (actual end, or nil if ongoing)
  # - inning_transitions: array of {label, start, end}
  def context_label(game_start:, game_end:, inning_transitions: [])
    t = created_at
    return 'Before Game' if t < game_start
    if game_end && t > game_end
      return 'After Game'
    end
    # Find the inning segment this thought falls into
    inning_transitions.each_with_index do |seg, idx|
      seg_start = seg[:start]
      seg_end = seg[:end] || (inning_transitions[idx+1] && inning_transitions[idx+1][:start]) || game_end
      if seg_start && seg_end && t >= seg_start && t < seg_end
        return "Posted: #{seg[:label]}"
      end
    end
    # If not found, but after last segment and before game_end
    if inning_transitions.last && t >= inning_transitions.last[:start] && (!game_end || t <= game_end)
      return "Posted: #{inning_transitions.last[:label]}"
    end
    'During Game'
  end
end