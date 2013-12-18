class AddUserIdToWidgets < ActiveRecord::Migration
  def change
    add_column :widgets, :user_id, :integer
    add_index  :widgets, :user_id
  end
end
