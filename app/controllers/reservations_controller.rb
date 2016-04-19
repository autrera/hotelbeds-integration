class ReservationsController < ApplicationController

  include BookingForm

  def new
    # hotel_rechecked_rates = File.read(Rails.root + "app/assets/jsons/recheck_rate.json")
    # @hotel = (JSON.parse hotel_rechecked_rates)['hotel']

    signature = generate_signature

    request = Typhoeus::Request.new(
      "https://api.test.hotelbeds.com/hotel-api/1.0/checkrates?rateKey=#{params['rateKey']}",
      method: :get,
      headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => "4whec3tnzq9abhrx2ku9n78t", 'X-Signature' => signature }
    )
    request.run
    @response = request.response
    @hotel = (JSON.parse @response.body)['hotel']

    Rails.logger.info "Response: #{@response.body.inspect}"
    Rails.logger.info "Hotel: #{@hotel.inspect}"
  end

  def create
    signature = generate_signature

    booking_structure = BookingStructure.new
    booking_structure.setParams params
    json_structure = JSON.generate booking_structure.generate

    request = Typhoeus::Request.new(
      "https://api.test.hotelbeds.com/hotel-api/1.0/bookings",
      method: :post,
      body: json_structure,
      headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => "4whec3tnzq9abhrx2ku9n78t", 'X-Signature' => signature }
    )
    request.run
    @response = request.response
    @body = JSON.parse @response.body

    Rails.logger.info "Response: #{@body.inspect}"
    # respond_to do |format|
    #   format.html { render json: JSON.generate(json_structure) }
    # end
  end
end
