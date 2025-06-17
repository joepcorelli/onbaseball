class Notification
  include Mongoid::Document
  include Mongoid::Timestamps

  field :type, type: String  # e.g., 'follow'
  field :read, type: Boolean, default: false
  field :message, type: String

  belongs_to :recipient, class_name: 'User', inverse_of: :received_notifications
  belongs_to :actor, class_name: 'User', inverse_of: :sent_notifications, optional: true

  # Create indexes for performance
  index({ recipient_id: 1, created_at: -1 })
  index({ recipient_id: 1, read: 1 })

  validates :type, presence: true
  validates :message, presence: true
  validates :recipient, presence: true

  scope :unread, -> { where(read: false) }
  scope :ordered, -> { order(created_at: :desc) }
end 