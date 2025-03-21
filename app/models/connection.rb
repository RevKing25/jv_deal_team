class Connection < ApplicationRecord
  belongs_to :requester, class_name: "User"
  belongs_to :receiver, class_name: "User"

  enum status: { pending: 0, accepted: 1, rejected: 2 }

  validates :requester_id, uniqueness: { scope: :receiver_id, message: "already requested to connect" }
  validate :not_self_connection

  after_create :increment_pending_connections_count, if: :pending?
  after_save :update_pending_connections_count
  after_destroy :decrement_pending_connections_count

  private

  def not_self_connection
    errors.add(:receiver_id, "cannot be the same as requester") if requester_id == receiver_id
  end

  def increment_pending_connections_count
    receiver.increment!(:pending_connections_count)
    Rails.logger.info "New pending connection created, incremented #{receiver.id}'s count to #{receiver.pending_connections_count}"
  end

  ddef update_pending_connections_count
  if saved_change_to_status?
    old_status, new_status = saved_changes[:status]
    Rails.logger.info "Connection #{id} status changed from #{self.statuses.key(old_status)} (#{old_status}) to #{self.statuses.key(new_status)} (#{new_status})"
    if new_status == 0 && old_status != 0  # Became pending
      receiver.increment!(:pending_connections_count)
      Rails.logger.info "Incremented #{receiver.id}'s count to #{receiver.pending_connections_count}"
    elsif old_status == 0 && new_status != 0  # Left pending
      receiver.decrement!(:pending_connections_count)
      Rails.logger.info "Decremented #{receiver.id}'s count to #{receiver.pending_connections_count}"
    end
  else
    Rails.logger.info "No status change for Connection #{id}"
  end
end

  def decrement_pending_connections_count
    if status == "pending"
      receiver.decrement!(:pending_connections_count)
      Rails.logger.info "Destroyed pending connection, decremented #{receiver.id}'s count to #{receiver.pending_connections_count}"
    end
  end
end