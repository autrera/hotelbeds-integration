class AddNameToAdministrator < ActiveRecord::Migration
  def change
    add_column :administrators, :name, :string
  end
end
