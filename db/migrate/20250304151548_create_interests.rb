class CreateInterests < ActiveRecord::Migration[7.0]
  def change
    create_table :interests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :property, null: false, foreign_key: true
      t.timestamps
    end

    # Add unique index to prevent duplicate interests
    add_index :interests, [:user_id, :property_id], unique: true
  end
end