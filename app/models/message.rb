class Message < ApplicationRecord
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id'
  belongs_to :property, optional: true
  belongs_to :parent_message, class_name: 'Message', optional: true
  has_many :replies, class_name: 'Message', foreign_key: 'parent_message_id', dependent: :nullify

  validates :content, presence: true
  validates :read, inclusion: { in: [true, false] }

  def mark_as_read
    update(read: true)
  end
end