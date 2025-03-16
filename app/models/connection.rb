class Connection < ApplicationRecord
  belongs_to :requester, class_name: "User"
  belongs_to :receiver, class_name: "User"

  enum status: { pending: 0, accepted: 1, rejected: 2 }

  validates :requester_id, uniqueness: { scope: :receiver_id, message: "already requested to connect" }
  validate :not_self_connection

  private

  def not_self_connection
    errors.add(:receiver_id, "cannot be the same as requester") if requester_id == receiver_id
  end
end