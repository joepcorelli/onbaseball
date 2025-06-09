class Vote
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :vote_type, type: String # 'like' or 'dislike'
  
  belongs_to :user
  belongs_to :game_thought
  
  validates :vote_type, presence: true, inclusion: { in: ['like', 'dislike'] }
  validates :user_id, uniqueness: { scope: :game_thought_id }
  
  index({ user_id: 1, game_thought_id: 1 }, { unique: true })
end