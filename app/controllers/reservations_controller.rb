class ReservationsController < ApplicationController

  include BookingForm

  def new
    # hotel_rechecked_rates = File.read(Rails.root + "app/assets/jsons/recheck_rate.json")
    # @hotel = (JSON.parse hotel_rechecked_rates)['hotel']

    signature = generate_signature
    availability_request_hash = generate_single_availability_request_hash(params)
    availability_request_hash.except! "destination"
    availability_request_hash["hotels"] = {
      hotel: [params[:hotel_code]]
    }
    availability_request_hash["rooms"] = {
      included: true,
      room: [params[:room_code]]
    }
    availability_request_hash["boards"] = {
      included: true,
      board: [params[:board_code]]
    }
    availability_request_hash["filter"] = {
      paymentType: "AT_WEB"
    }

    availability_request = Typhoeus::Request.new(
      "https://api.test.hotelbeds.com/hotel-api/1.0/hotels",
      method: :post,
      body: JSON.generate(availability_request_hash),
      headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => "4whec3tnzq9abhrx2ku9n78t", 'X-Signature' => signature }
    )
    availability_request.on_complete do |response|
      if response.success?
        @hotel_availability = JSON.parse response.body
        # Rails.logger.info "Hotels Availability: #{response.body.inspect}"
      else
        # Rails.logger.info response.body.inspect
      end
    end
    availability_request.run
    @response = availability_request.response
    @hotel = JSON.parse @response.body

    rate_keys_hash = {
      rooms: []
    }
    @hotel['hotels']['hotels'][0]['rooms'][0]['rates'].each_with_index do |rate, index|
      rate_keys_hash[:rooms][index] = {
        rateKey: rate['rateKey']
      }
    end

    # respond_to do |format|
    #   format.html { render json: @hotel }
    # end

    # signature = generate_signature

    request = Typhoeus::Request.new(
      "https://api.test.hotelbeds.com/hotel-api/1.0/checkrates",
      method: :post,
      body: JSON.generate(rate_keys_hash),
      headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => "4whec3tnzq9abhrx2ku9n78t", 'X-Signature' => signature }
    )
    request.run
    @response = request.response
    @hotel = (JSON.parse @response.body)['hotel']
  end

  def create
    signature = generate_signature

    booking_structure = BookingStructure.new
    booking_structure.setParams params
    json_structure = JSON.generate booking_structure.generate

    reservation_request = Typhoeus::Request.new(
      "https://api.test.hotelbeds.com/hotel-api/1.0/bookings",
      method: :post,
      body: json_structure,
      headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => "4whec3tnzq9abhrx2ku9n78t", 'X-Signature' => signature }
    )
    reservation_request.on_complete do |response|
      if response.success?
        response_body_json = JSON.parse response.body
        @reservation = response_body_json['booking']
        Rails.logger.info "Reservation: #{response.body.inspect}"
      else
        Rails.logger.info response.body.inspect
      end
    end

    content_request = Typhoeus::Request.new(
      "https://api.test.hotelbeds.com/hotel-content-api/1.0/hotels/#{@hotel_code}",
      method: :get,
      # params: content_request_hash,
      headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => "4whec3tnzq9abhrx2ku9n78t", 'X-Signature' => signature }
    )
    content_request.on_complete do |response|
      if response.success?
        response_body_json = JSON.parse response.body
        @hotel_content = response_body_json['hotel']
        Rails.logger.info "Hotels Content: #{response.body.inspect}"
      else
        Rails.logger.info response.body.inspect
      end
    end

    hydra = Typhoeus::Hydra.hydra
    hydra.queue reservation_request
    hydra.queue content_request
    hydra.run

    # reservation_request.run
    # @response = reservation_request.response
    # response_body_json = JSON.parse @response.body
    # @reservation = response_body_json['booking']

    Rails.logger.info "Respuesta: #{@reservation.inspect}"

    if @reservation['status'] == "CONFIRMED"
      # Send client email
      ReservationMailer.client_confirmation(params[:holder_email], @reservation, @hotel_content).deliver
      # Send agents email
      redirect_to confirmation_reservations_path success: true
    else
      redirect_to confirmation_reservations_path error: true
    end

    # respond_to do |format|
    #   format.html { render json: @reservation }
    # end
  end

  def confirmation
    unless params[:error] == 'true'
      render 'success'
    else
      render 'error'
    end
  end

end
