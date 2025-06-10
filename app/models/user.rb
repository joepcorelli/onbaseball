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

  # Game thoughts and votes
  has_many :game_thoughts, dependent: :destroy
  has_many :votes, dependent: :destroy

  # Validations for display name
  validates :display_name, presence: true, length: { minimum: 2, maximum: 30 }
  validates :display_name, uniqueness: { case_sensitive: false }
  validates :display_name, format: { 
    with: /\A[a-zA-Z0-9_\-\s]+\z/, 
    message: "can only contain letters, numbers, underscores, hyphens, and spaces" 
  }

  # Set default display name before validation on create
  before_validation :set_default_display_name, on: :create

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
