class HotelsController < ApplicationController

  include HotelHelper
  include BookingForm

  def index
    @country_code, @destination_code, @zone_code = params['destination'].split '-'

    destinations_file = File.read(Rails.root + "app/assets/jsons/destinations.json")
    @destinations = JSON.parse destinations_file

    signature = generate_signature
    availability_request_hash = generate_availability_request_hash(params)
    content_request_hash = generate_content_request_hash(params)

    # respond_to do |format|
    #   format.html { render json: JSON.generate(hash_structure) }
    # end

    # hotels_availability_file = File.read(Rails.root + "app/assets/jsons/hotels_availability.json")
    # @hotels_availability = JSON.parse hotels_availability_file

    # hotels_content_file = File.read(Rails.root + "app/assets/jsons/hotels_content.json")
    # @hotels_content = JSON.parse hotels_content_file

    availability_request = Typhoeus::Request.new(
      "https://api.test.hotelbeds.com/hotel-api/1.0/hotels",
      method: :post,
      body: JSON.generate(availability_request_hash),
      headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => "4whec3tnzq9abhrx2ku9n78t", 'X-Signature' => signature }
    )
    availability_request.on_complete do |response|
      if response.success?
        @hotels_availability = JSON.parse response.body
        Rails.logger.info "Hotels Availability: #{response.body.inspect}"
      else
        Rails.logger.info response.body.inspect
      end
    end

    content_request = Typhoeus::Request.new(
      "https://api.test.hotelbeds.com/hotel-content-api/1.0/hotels",
      method: :get,
      params: content_request_hash,
      headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => "4whec3tnzq9abhrx2ku9n78t", 'X-Signature' => signature }
    )
    content_request.on_complete do |response|
      if response.success?
        @hotels_content = JSON.parse response.body
        # Rails.logger.info "Hotels Content: #{response.body.inspect}"
      else
        Rails.logger.info response.body.inspect
      end
    end

    hydra = Typhoeus::Hydra.hydra
    hydra.queue availability_request
    hydra.queue content_request
    # hydra.run

    if @hotels_content != nil && @hotels_availability != nil
      # Redirect to error page or sth
    end

    # request.run
    # @response = request.response
    # @body = JSON.parse @response.body
  end

  def show
    @hotel_code = params[:id].split('-').pop.to_i

    destinations_file = File.read(Rails.root + "app/assets/jsons/destinations.json")
    @destinations = JSON.parse destinations_file

    hotel_file = File.read(Rails.root + "app/assets/jsons/hotel_availability.json")
    @hotel = JSON.parse hotel_file

    hotel_content_file = File.read(Rails.root + "app/assets/jsons/hotel_content.json")
    @hotel_content = JSON.parse hotel_content_file
  end
end
