class MakePropertyIdNullableInMessages < ActiveRecord::Migration[7.0]  # Adjust version if needed
  def change
    # Remove the existing foreign key constraint
    remove_foreign_key :messages, :properties

    # Change property_id to allow null values
    change_column_null :messages, :property_id, true

    # Add the foreign key back with on_delete: :nullify
    add_foreign_key :messages, :properties, on_delete: :nullify
  end
end