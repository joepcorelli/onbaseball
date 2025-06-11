class Follow
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'
  
  # Ensure a user can't follow the same person twice
  validates :follower_id, uniqueness: { scope: :followed_id }
  # Ensure a user can't follow themselves
  validate :cannot_follow_self
  
  # Create indexes for performance
  index({ follower_id: 1, followed_id: 1 }, { unique: true })
  index({ follower_id: 1 })
  index({ followed_id: 1 })
  
  private
  
  def cannot_follow_self
    errors.add(:followed, "can't follow yourself") if follower_id == followed_id
  end
end