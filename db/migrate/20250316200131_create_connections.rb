class CreateConnections < ActiveRecord::Migration[7.0]  # Adjust version if needed
  def change
    create_table :connections do |t|
      t.references :requester, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.integer :status, default: 0  # 0: pending, 1: accepted, 2: rejected

      t.timestamps
    end

    # Ensure a user can't connect with themselves and prevent duplicates
    add_index :connections, [:requester_id, :receiver_id], unique: true
  end
end
