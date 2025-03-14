class SetDefaultRoleForUsers < ActiveRecord::Migration[7.1]
  def change
    change_column_default :users, :role, "both"
  end
end