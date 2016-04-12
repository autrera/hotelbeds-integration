class ReservationsController < ApplicationController
  def new
    hotel_rechecked_rates = File.read(Rails.root + "app/assets/jsons/recheck_rate.json")
    @hotel = (JSON.parse hotel_rechecked_rates)['hotel']
  end

  def create
    booking_structure = BookingStructure.new
    booking_structure.setParams params
    json_structure = booking_structure.generate
    respond_to do |format|
      format.html { render json: JSON.generate(json_structure) }
    end
  end
end
