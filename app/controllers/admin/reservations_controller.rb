class Admin::ReservationsController < AdminController

  include BookingForm
  include ReservationHelper

  def index
    signature = generate_signature

    start_date = params[:start_date] != nil ? Date.strptime(params[:start_date], '%m/%d/%Y') : (Date.today - 30.days)
    end_date = params[:end_date] != nil ? Date.strptime(params[:end_date], '%m/%d/%Y') : Date.today

    reservations_params_hash = {
      start: start_date.strftime('%F'),
      end: end_date.strftime('%F'),
      includeCancelled: true,
      filterType: 'CREATION',
      from: params[:from] || 1,
      to: params[:to] || 25
    }

    reservations_list_request = Typhoeus::Request.new(
      "https://api.test.hotelbeds.com/hotel-api/1.0/bookings",
      method: :get,
      params: reservations_params_hash,
      headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => "4whec3tnzq9abhrx2ku9n78t", 'X-Signature' => signature }
    )
    reservations_list_request.run
    response = reservations_list_request.response
    reservations_body = JSON.parse response.body

    # Rails.logger.info "Response: #{response.body.inspect}"

    @reservations = reservations_body['bookings']
  end

end
