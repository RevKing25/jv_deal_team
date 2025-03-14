class AddStatesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :states, :string, default: "[]"
  end
end
