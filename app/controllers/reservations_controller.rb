class ReservationsController < ApplicationController

  force_ssl if: :ssl_configured?

  require 'paypal-sdk-rest'

  include PayPal::SDK::REST
  include BookingForm
  include HotelHelper

  def new

    rate_keys_hash = {
      language: 'CAS',
      rooms: []
    }
    params[:rate_key].each_with_index do |rate, index|
      rate_keys_hash[:rooms][index] = {
        rateKey: rate
      }
    end

    # Rails.logger.info "Rate Keys: #{JSON.generate(rate_keys_hash)}"

    signature = generate_signature

    check_rates_request = Typhoeus::Request.new(
      "https://api.test.hotelbeds.com/hotel-api/1.0/checkrates",
      method: :post,
      body: JSON.generate(rate_keys_hash),
      accept_encoding: "gzip",
      headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => "4whec3tnzq9abhrx2ku9n78t", 'X-Signature' => signature }
    )
    check_rates_request.run
    @response = check_rates_request.response
    @hotel = (JSON.parse @response.body)['hotel']

    # Rails.logger.info "Recheck Rates Response: #{@response.body}"
  end

  def payment
    rate_keys_hash = {
      language: 'CAS',
      rooms: []
    }
    (1..params['number_of_rooms'].to_i).to_a.each_with_index do |number_of_room, index|
      rate_keys_hash[:rooms][index] = {
        rateKey: params["room_#{number_of_room}_rateKey"]
      }
    end

    signature = generate_signature

    # Rails.logger.info "Rate Keys: #{JSON.generate(rate_keys_hash)}"

    check_rates_request = Typhoeus::Request.new(
      "https://api.test.hotelbeds.com/hotel-api/1.0/checkrates",
      method: :post,
      body: JSON.generate(rate_keys_hash),
      accept_encoding: "gzip",
      headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => "4whec3tnzq9abhrx2ku9n78t", 'X-Signature' => signature }
    )
    check_rates_request.run
    @response = check_rates_request.response
    @hotel = (JSON.parse @response.body)['hotel']

    client_total = Money.new(0, @hotel['currency'])
    @hotel['rooms'].each do |room|
      room['rates'].each do |rate|
        client_total += (calculate_gross_room_rate(rate, @hotel['currency']))['client_total']
      end
    end

    PayPal::SDK::REST.set_config(
      :mode => "sandbox", # "sandbox" or "live"
      :client_id => ENV['PAYPAL_CLIENT_ID'],
      :client_secret => ENV['PAYPAL_CLIENT_SECRET']
    )

    payment = Payment.new({
      :intent => "sale",
      :redirect_urls => {
        :return_url => ENV['PAYPAL_RETURN_URL'] + "?" + request.query_parameters.to_query,
        :cancel_url => ENV['PAYPAL_CANCEL_URL']
      },
      :payer => {
        :payment_method => "paypal"
      },
      :transactions => [{
        :amount => {
          :total => client_total.amount,
          :currency => client_total.currency.iso_code
        },
        :description => "NeanderTravel Reservación."
      }]
    })

    Rails.logger.info "Pago: #{payment.inspect}"

    if payment.create
      # payment.id     # Payment Id
      Rails.logger.info "Pago ID: #{payment.id.inspect}"
      redirect_url = payment.links.find{|v| v.method == "REDIRECT" }.href
      redirect_to redirect_url
      return
    else
      # payment.error  # Error Hash
      Rails.logger.info "Pago Error: #{payment.error.inspect}"
      redirect_to(:back, :flash => { :error => "No se pudo realizar el cargo." })
      return
    end

  end

  def book

    rate_keys_hash = {
      language: 'CAS',
      rooms: []
    }
    (1..params['number_of_rooms'].to_i).to_a.each_with_index do |number_of_room, index|
      rate_keys_hash[:rooms][index] = {
        rateKey: params["room_#{number_of_room}_rateKey"]
      }
    end

    signature = generate_signature

    # Rails.logger.info "Rate Keys: #{JSON.generate(rate_keys_hash)}"

    check_rates_request = Typhoeus::Request.new(
      "https://api.test.hotelbeds.com/hotel-api/1.0/checkrates",
      method: :post,
      body: JSON.generate(rate_keys_hash),
      accept_encoding: "gzip",
      headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => "4whec3tnzq9abhrx2ku9n78t", 'X-Signature' => signature }
    )
    check_rates_request.run
    @response = check_rates_request.response
    @hotel = (JSON.parse @response.body)['hotel']

    client_total = Money.new(0, @hotel['currency'])
    @hotel['rooms'].each do |room|
      room['rates'].each do |rate|
        client_total += (calculate_gross_room_rate(rate, @hotel['currency']))['client_total']
      end
    end

    # Rails.logger.info "Total del Cliente: #{client_total.inspect}"

    PayPal::SDK::REST.set_config(
      :mode => "sandbox", # "sandbox" or "live"
      :client_id => ENV['PAYPAL_CLIENT_ID'],
      :client_secret => ENV['PAYPAL_CLIENT_SECRET']
    )

    payment = Payment.find(params[:paymentId])

    if payment.execute(:payer_id => params[:PayerID])
      Rails.logger.info "Pago ID: #{payment.id.inspect}"
    else
      Rails.logger.info "Pago Error: #{payment.error.inspect}"
      redirect_to(:back, :flash => { :error => "No se pudo realizar el cargo." })
      return
    end

    params[:holder_email] = params[:holder_email].downcase

    # require "conekta"
    # Conekta.api_key = "key_45w4WQNv6Y4icr2uz8yVGA"

    # Rails.logger.info "Token: #{params[:conektaTokenId]}"

    # begin
    #   charge = Conekta::Charge.create({
    #     "amount"=> client_total.cents,
    #     "currency"=> @hotel['currency'],
    #     "description"=> "Neandertravel Reservación",
    #     "reference_id"=> "orden_de_id_interno",
    #     "card"=> params[:conektaTokenId],  # Ej. "tok_a4Ff0dD2xYZZq82d9"
    #     "details"=> {
    #       "name"=> params[:card_holder_name],
    #       "phone"=> params[:holder_phone],
    #       "email"=> params[:holder_email],
    #       # "customer"=> {
    #       #   "logged_in"=> true,
    #       #   "successful_purchases"=> 14,
    #       #   "created_at"=> 1379784950,
    #       #   "updated_at"=> 1379784950,
    #       #   "offline_payments"=> 4,
    #       #   "score"=> 9
    #       # },
    #       "line_items"=> [{
    #         "name"=> "Box of Cohiba S1s",
    #         "description"=> "Imported From Mex.",
    #         "unit_price"=> 20000,
    #         "quantity"=> 1,
    #         "sku"=> "cohb_s1",
    #         "category"=> "food"
    #       }]
    #     }
    #   })

    # rescue Conekta::ParameterValidationError => e
    #   Rails.logger.info "ParameterValidationError: #{e.message_to_purchaser}"
    #   # puts e.message_to_purchaser
    #   #alguno de los parámetros fueron inválidos

    # rescue Conekta::ProcessingError => e
    #   Rails.logger.info "ProcessingError: #{e.message_to_purchaser}"
    #   # puts e.message_to_purchaser
    #   #la tarjeta no pudo ser procesada

    # rescue Conekta::Error => e
    #   Rails.logger.info "Error: #{e.message_to_purchaser}"
    #   # puts e.message_to_purchaser
    #   #un error ocurrió que no sucede en el flujo normal de cobros como por ejemplo un auth_key incorrecto

    # end

    # Rails.logger.info "Cargo: #{charge.inspect}"

    # if charge == nil
    #   redirect_to(:back, :flash => { :error => "No se pudo realizar el cargo." })
    #   return
    # end
    # unless charge.status == "paid"
    #   redirect_to(:back, :flash => { :error => "No se pudo realizar el cargo." })
    #   return
    # end

    signature = generate_signature

    booking_structure = BookingStructure.new
    booking_structure.setParams params
    json_structure = JSON.generate booking_structure.generate

    # Rails.logger.info "JSON Structure: #{json_structure}"

    reservation_request = Typhoeus::Request.new(
      "https://api.test.hotelbeds.com/hotel-api/1.0/bookings",
      method: :post,
      body: json_structure,
      accept_encoding: "gzip",
      headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => "4whec3tnzq9abhrx2ku9n78t", 'X-Signature' => signature }
    )
    reservation_request.on_complete do |response|
      if response.success?
        response_body_json = JSON.parse response.body
        @reservation = response_body_json['booking']
        # Rails.logger.info "Reservation: #{response.body}"
      else
        Rails.logger.info "Reservation: #{response.body}"
      end
    end

    content_request = Typhoeus::Request.new(
      "https://api.test.hotelbeds.com/hotel-content-api/1.0/hotels/#{params[:hotel_id]}?language=CAS",
      method: :get,
      params: { fields: "all" },
      accept_encoding: "gzip",
      headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => "4whec3tnzq9abhrx2ku9n78t", 'X-Signature' => signature }
    )
    content_request.on_complete do |response|
      if response.success?
        response_body_json = JSON.parse response.body
        @hotel_content = response_body_json['hotel']
        # Rails.logger.info "Hotels Content: #{response.body}"
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

    # Rails.logger.info "Respuesta: #{@reservation.inspect}"

    unless @reservation.has_key? 'status'
      redirect_to error_reservations_path error: true
      return
    end

    if @reservation['status'] == "CONFIRMED"
      # Rails.logger.info "Email: #{params[:holder_email].inspect}"
      client = Client.find_by_email params[:holder_email]
      # Rails.logger.info "Cliente: #{client.inspect}"
      if client == nil
        client = Client.new
        client.name = params[:holder_name]
        client.surname = params[:holder_surname]
        client.email = params[:holder_email]

        password = (0...8).map { (65 + rand(26)).chr }.join
        client.password = password
        unless client.save
          Rails.logger.info "No se guardo al usuario"
        end
      end

      reservation = client.reservations.create({
        reference: @reservation['reference'],
        status: @reservation['status'],
        check_in: @reservation['hotel']['checkIn'],
        check_out: @reservation['hotel']['checkOut'],
        holder_name: @reservation['holder']['name'],
        holder_surname: @reservation['holder']['surname'],
        hotel_id: @reservation['hotel']['code'],
        hotel_name: @reservation['hotel']['name'],
        destination_code: @reservation['hotel']['destinationCode'],
        destination_name: @reservation['hotel']['destinationName'],
        zone_code: @reservation['hotel']['zoneCode'],
        zone_name: @reservation['hotel']['zoneName'],
        latitude: @reservation['hotel']['latitude'],
        longitude: @reservation['hotel']['longitude'],
        rooms: @reservation['hotel']['rooms'],
        supplier: @reservation['hotel']['supplier'],
        client_total: client_total.cents,
        supplier_net_total: @reservation['totalNet'],
        currency: @reservation['currency'],
        payment_id: params[:paymentId],
        payer_id: params[:PayerID]
      })

      # Send client email
      ReservationMailer.client_confirmation(params[:holder_email], @reservation, @hotel_content, client_total).deliver_now
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

  private

    def ssl_configured?
      !Rails.env.development?
    end

end
