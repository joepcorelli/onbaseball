class User
  include Mongoid::Document
  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time
  include Mongoid::Timestamps
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Add display name field
  field :display_name, type: String
  field :favorite_team, type: String

  # Game thoughts and votes
  has_many :game_thoughts, dependent: :destroy
  has_many :votes, dependent: :destroy

  # Follow relationships
  has_many :active_follows, class_name: 'Follow', foreign_key: 'follower_id', dependent: :destroy, inverse_of: :follower
  has_many :passive_follows, class_name: 'Follow', foreign_key: 'followed_id', dependent: :destroy, inverse_of: :followed

  # Notifications
  has_many :notifications, foreign_key: 'recipient_id', dependent: :destroy

  # Validations for display name
  validates :display_name, presence: true, length: { minimum: 2, maximum: 30 }
  validates :display_name, uniqueness: { case_sensitive: false }
  validates :display_name, format: { 
    with: /\A[a-zA-Z0-9_\-\s]+\z/, 
    message: "can only contain letters, numbers, underscores, hyphens, and spaces" 
  }

  # Validation for favorite team
  validates :favorite_team, inclusion: { 
    in: %w[
      Arizona\ Diamondbacks
      Atlanta\ Braves
      Baltimore\ Orioles
      Boston\ Red\ Sox
      Chicago\ Cubs
      Chicago\ White\ Sox
      Cincinnati\ Reds
      Cleveland\ Guardians
      Colorado\ Rockies
      Detroit\ Tigers
      Houston\ Astros
      Kansas\ City\ Royals
      Los\ Angeles\ Angels
      Los\ Angeles\ Dodgers
      Miami\ Marlins
      Milwaukee\ Brewers
      Minnesota\ Twins
      New\ York\ Mets
      New\ York\ Yankees
      Oakland\ Athletics
      Philadelphia\ Phillies
      Pittsburgh\ Pirates
      San\ Diego\ Padres
      San\ Francisco\ Giants
      Seattle\ Mariners
      St.\ Louis\ Cardinals
      Tampa\ Bay\ Rays
      Texas\ Rangers
      Toronto\ Blue\ Jays
      Washington\ Nationals
    ],
    allow_nil: true,
    message: "must be a valid MLB team name"
  }

  # Set default display name before validation on create
  before_validation :set_default_display_name, on: :create

  # Helper methods for follow functionality - REORDERED TO FIX CIRCULAR REFERENCE
  # Get users this user is following (MOVED UP)
  def following
    User.in(id: active_follows.pluck(:followed_id))
  end

  # Get users following this user (MOVED UP)
  def followers
    User.in(id: passive_follows.pluck(:follower_id))
  end

  def follow(user)
    return false if self == user || following?(user)
    active_follows.create(followed: user)
  end

  def unfollow(user)
    active_follows.where(followed: user).destroy_all
  end

  def following?(user)
    following.include?(user)  # Now this works because 'following' method is defined above
  end

  def followers_count
    passive_follows.count
  end

  def following_count
    active_follows.count
  end

  # Notification methods
  def unread_notifications_count
    notifications.unread.count
  end

  def mark_notifications_as_read
    notifications.unread.update_all(read: true)
  end

  private

  def set_default_display_name
    if display_name.blank?
      # Extract username from email (part before @)
      self.display_name = email.split('@').first if email.present?
    end
  end

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  # field :sign_in_count,      type: Integer, default: 0
  # field :current_sign_in_at, type: Time
  # field :last_sign_in_at,    type: Time
  # field :current_sign_in_ip, type: String
  # field :last_sign_in_ip,    type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

end
