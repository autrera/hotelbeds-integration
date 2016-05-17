class AddReferenceToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :reference, :string
  end
end
