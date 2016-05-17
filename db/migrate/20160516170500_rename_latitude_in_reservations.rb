class RenameLatitudeInReservations < ActiveRecord::Migration
  def change
    rename_column :reservations, :latitde, :latitude
  end
end
