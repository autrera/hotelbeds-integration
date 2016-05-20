class Client::ReservationsController < ClientController

  include BookingForm

  before_action :set_client, only: [:index]

  def index
    Rails.logger.info "Cliente: #{@client.inspect}"
    @reservations = @client.reservations
  end

  def show
    signature = generate_signature

    reservation_request = Typhoeus::Request.new(
      "https://api.test.hotelbeds.com/hotel-api/1.0/bookings/#{params[:id]}",
      method: :get,
      headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => "4whec3tnzq9abhrx2ku9n78t", 'X-Signature' => signature }
    )
    reservation_request.run
    response = reservation_request.response
    reservation_body = JSON.parse response.body

    Rails.logger.info "Response: #{reservation_body.inspect}"

    @reservation = reservation_body['booking']
    @local_reservation = Reservation.find_by_reference params[:id]

    redirect_to admin_reservations_path, alert: "No encontramos ninguna reservación con ese ID." unless @reservation != nil
  end

  private

    def set_client
      @client = current_client_client
    end

end
