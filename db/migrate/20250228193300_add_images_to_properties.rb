class AddImagesToProperties < ActiveRecord::Migration[7.1]
  def change
    add_column :properties, :images, :json, default: []
  end
end