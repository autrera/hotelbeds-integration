class ReservationsController < ApplicationController
  def new
    hotel_rechecked_rates = File.read(Rails.root + "app/assets/jsons/recheck_rate.json")
    @hotel = (JSON.parse hotel_rechecked_rates)['hotel']
  end
end
