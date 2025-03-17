class Connection < ApplicationRecord
  belongs_to :requester, class_name: "User"
  belongs_to :receiver, class_name: "User", counter_cache: :pending_connections_count

  enum status: { pending: 0, accepted: 1, rejected: 2 }

  validates :requester_id, uniqueness: { scope: :receiver_id, message: "already requested to connect" }
  validate :not_self_connection

  after_save :update_pending_connections_count
  after_destroy :decrement_pending_connections_count

  private

  def not_self_connection
    errors.add(:receiver_id, "cannot be the same as requester") if requester_id == receiver_id
  end

  def update_pending_connections_count
    if saved_change_to_status?
      if status == "pending"
        receiver.increment!(:pending_connections_count) unless previous_changes[:status].nil? # Don't increment on create
      elsif status_was == "pending"
        receiver.decrement!(:pending_connections_count)
      end
    end
  end

  def decrement_pending_connections_count
    receiver.decrement!(:pending_connections_count) if status == "pending"
  end
end