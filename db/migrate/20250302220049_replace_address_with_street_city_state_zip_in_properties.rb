class ReplaceAddressWithStreetCityStateZipInProperties < ActiveRecord::Migration[7.1]
  def change
    # Add new columns without NOT NULL constraints initially
    add_column :properties, :street_address, :string
    add_column :properties, :city, :string
    add_column :properties, :state, :string
    add_column :properties, :zip_code, :string

    # Backfill existing records by splitting address or using placeholders
    reversible do |dir|
      dir.up do
        Property.find_each do |property|
          if property.address.present?
            # Attempt to split address (simplified example; adjust based on format)
            parts = property.address.split(',').map(&:strip)
            property.street_address = parts[0] || "Unknown Street"
            property.city = parts[1] || "Unknown City"
            property.state = parts[2] || "Unknown State"
            property.zip_code = parts[3] || "00000"
          else
            # If address is blank, use placeholders
            property.street_address = "Unknown Street"
            property.city = "Unknown City"
            property.state = "Unknown State"
            property.zip_code = "00000"
          end
          property.save!(validate: false) # Skip validations for this step
        end
      end
    end

    # Now add NOT NULL constraints after backfilling
    change_column_null :properties, :street_address, false
    change_column_null :properties, :city, false
    change_column_null :properties, :state, false
    change_column_null :properties, :zip_code, false

    # Remove the old address column
    remove_column :properties, :address, :string
  end
end