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
    # availability_request.on_complete do |response|
    #   if response.success?
    #     @hotel_availability = JSON.parse response.body
    #     # Rails.logger.info "Hotels Availability: #{response.body.inspect}"
    #   else
    #     # Rails.logger.info response.body.inspect
    #   end
    # end
    availability_request.run
    @response = availability_request.response
    @hotel = JSON.parse @response.body

    Rails.logger.info "Availability Request: #{JSON.generate(availability_request_hash)}"
    Rails.logger.info "Hotel: #{@hotel.inspect}"

    rate_keys_hash = {
      rooms: []
    }
    @hotel['hotels']['hotels'][0]['rooms'][0]['rates'].each_with_index do |rate, index|
      rate_keys_hash[:rooms][index] = {
        rateKey: rate['rateKey']
      }
    end

    # respond_to do |format|
    #   format.html { render json: JSON.generate(rate_keys_hash) }
    # end

    # signature = generate_signature

    check_rates_request = Typhoeus::Request.new(
      "https://api.test.hotelbeds.com/hotel-api/1.0/checkrates",
      method: :post,
      body: JSON.generate(rate_keys_hash),
      headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => "4whec3tnzq9abhrx2ku9n78t", 'X-Signature' => signature }
    )
    check_rates_request.run
    @response = check_rates_request.response
    @hotel = (JSON.parse @response.body)['hotel']

    Rails.logger.info "Response: #{@response.body.inspect}"
  end

  def create
    require "conekta"
    Conekta.api_key = "key_45w4WQNv6Y4icr2uz8yVGA"

    Rails.logger.info "Token: #{params[:conektaTokenId]}"

    begin
      charge = Conekta::Charge.create({
        "amount"=> 51000,
        "currency"=> "MXN",
        "description"=> "Neandertravel Reservación",
        "reference_id"=> "orden_de_id_interno",
        "card"=> params[:conektaTokenId],  # Ej. "tok_a4Ff0dD2xYZZq82d9"
        "details"=> {
          "name"=> params[:card_holder_name],
          "phone"=> params[:holder_phone],
          "email"=> params[:holder_email],
          # "customer"=> {
          #   "logged_in"=> true,
          #   "successful_purchases"=> 14,
          #   "created_at"=> 1379784950,
          #   "updated_at"=> 1379784950,
          #   "offline_payments"=> 4,
          #   "score"=> 9
          # },
          "line_items"=> [{
            "name"=> "Box of Cohiba S1s",
            "description"=> "Imported From Mex.",
            "unit_price"=> 20000,
            "quantity"=> 1,
            "sku"=> "cohb_s1",
            "category"=> "food"
          }]
        }
      })

    rescue Conekta::ParameterValidationError => e
      Rails.logger.info "ParameterValidationError: #{e.message_to_purchaser}"
      # puts e.message_to_purchaser
      #alguno de los parámetros fueron inválidos

    rescue Conekta::ProcessingError => e
      Rails.logger.info "ProcessingError: #{e.message_to_purchaser}"
      # puts e.message_to_purchaser
      #la tarjeta no pudo ser procesada

    rescue Conekta::Error => e
      Rails.logger.info "Error: #{e.message_to_purchaser}"
      # puts e.message_to_purchaser
      #un error ocurrió que no sucede en el flujo normal de cobros como por ejemplo un auth_key incorrecto

    end

    Rails.logger.info "Cargo: #{charge.inspect}"

    render :back unless charge.status == "paid"

    signature = generate_signature

    booking_structure = BookingStructure.new
    booking_structure.setParams params
    json_structure = JSON.generate booking_structure.generate

    Rails.logger.info "JSON Structure: #{json_structure}"

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
        Rails.logger.info "Reservation: #{response.body.inspect}"
      end
    end

    content_request = Typhoeus::Request.new(
      "https://api.test.hotelbeds.com/hotel-content-api/1.0/hotels/#{@hotel_code}",
      method: :get,
      params: { fields: "all" },
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
      # ReservationMailer.client_confirmation(params[:holder_email], @reservation, @hotel_content).deliver
      # Send agents email
      redirect_to success_reservations_path success: true
    else
      redirect_to error_reservations_path error: true
    end

    # respond_to do |format|
    #   format.html { render json: @reservation }
    # end
  end

  def success
  end

  def error
  end

  def confirmation
    unless params[:error] == 'true'
      render 'success'
    else
      render 'error'
    end
  end

end
