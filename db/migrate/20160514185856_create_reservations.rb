class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.string :status
      t.string :check_in
      t.string :check_out
      t.string :holder_name
      t.string :holder_surname
      t.int :hotel_id
      t.string :hotel_name
      t.string :destination_code
      t.string :destination_name
      t.int :zone_code
      t.string :zone_name
      t.string :latitde
      t.string :longitude
      t.text :rooms
      t.text :supplier
      t.string :client_total
      t.string :supplier_net_total
      t.string :currency
      t.int :client_id

      t.timestamps null: false
    end
  end
end
