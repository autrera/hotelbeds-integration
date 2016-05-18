class ChangeClientTotalTypeInReservations < ActiveRecord::Migration
  def change
    change_column :reservations, :client_total,  'integer USING CAST(client_total AS integer)'
  end
end
