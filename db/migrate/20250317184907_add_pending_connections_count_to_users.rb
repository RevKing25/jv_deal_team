class AddPendingConnectionsCountToUsers < ActiveRecord::Migration[7.1]  # Adjust version to match your Rails version (likely 7.1.5.1)
  def change
    add_column :users, :pending_connections_count, :integer, default: 0, null: false

    # Populate existing counts
    reversible do |dir|
      dir.up do
        User.find_each do |user|
          count = user.received_connections.where(status: Connection.statuses[:pending]).count
          user.update_column(:pending_connections_count, count)
        end
      end
    end
  end
end
