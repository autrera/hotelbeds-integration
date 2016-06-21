class AddPaymentInfoToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :payment_id, :string
    add_column :reservations, :payer_id, :string
  end
end
