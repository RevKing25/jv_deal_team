class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
  has_many :properties
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id'
  has_many :received_messages, class_name: 'Message', foreign_key: 'receiver_id'
  has_many :interests, dependent: :destroy
  has_many :interested_properties, through: :interests, source: :property
  validates :role, presence: true, inclusion: { in: %w(acquisitions dispo both), message: "must be 'Acquisitions', 'Dispo', or 'Both'" }
  validates :states, inclusion: { in: Property::US_STATES.map(&:last), message: "must be valid US state abbreviations" }, allow_blank: true

  attribute :states, :string, array: true, default: -> { [] }

  def states_display
    states.map { |abbr| Property::US_STATES.find { |s| s[1] == abbr }&.first || abbr }.join(", ")
  end

  before_validation :clean_states

  mount_uploader :profile_photo, ProfilePhotoUploader

  validates :name, presence: true, unless: :resetting_password?

  def unread_messages_count
    received_messages.where(read: false).count
  end

  def conversation_partners
    sent_message_recipients = sent_messages.pluck(:receiver_id).uniq
    received_message_senders = received_messages.pluck(:sender_id).uniq
    all_partner_ids = (sent_message_recipients + received_message_senders).uniq - [id]
    User.where(id: all_partner_ids)
  end

  def messages_with(other_user)
    Message.where(
      "(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)",
      self.id, other_user.id, other_user.id, self.id
    ).order(created_at: :asc)
  end

  private

  def resetting_password?
    reset_password_token.present? || persisted? && reset_password_sent_at.present?
  end
  def clean_states
    self.states = states.reject(&:blank?) if states.present?
  end
end