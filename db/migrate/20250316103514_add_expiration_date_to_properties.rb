class AddExpirationDateToProperties < ActiveRecord::Migration[7.1]
  def change
    add_column :properties, :expiration_date, :timestamptz, null: false, default: -> { "CURRENT_TIMESTAMP + INTERVAL '30 days'" }
  end
end