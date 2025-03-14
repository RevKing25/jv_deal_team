class ChangeStatesToArrayInUsers < ActiveRecord::Migration[7.1]
  def up
    # Remove the default value first
    change_column_default :users, :states, nil

    # Change type to text[] with data conversion
    execute <<-SQL
      ALTER TABLE users
      ALTER COLUMN states
      TYPE text[]
      USING CASE
        WHEN states = '[]' OR states IS NULL THEN '{}'
        ELSE string_to_array(regexp_replace(states, '[\\[\\]"]', '', 'g'), ',')
      END;
    SQL

    # Optionally set a new default (empty array)
    change_column_default :users, :states, '{}'
  end

  def down
    # Revert to string with default "[]"
    change_column_default :users, :states, nil
    change_column :users, :states, :string, default: "[]"
  end
end