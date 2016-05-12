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
    availability_request_hash["filter"] = {
      paymentType: "AT_WEB"
    }

    Rails.logger.info "Availability Hash #{JSON.generate(availability_request_hash)}"
    # respond_to do |format|
    #   format.html { render json: JSON.generate(availability_request_hash) }
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
        # Rails.logger.info "Hotels Availability: #{response.body.inspect}"
      else
        # Rails.logger.info response.body.inspect
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
        # Rails.logger.info response.body.inspect
      end
    end

    hydra = Typhoeus::Hydra.hydra
    hydra.queue availability_request
    hydra.queue content_request
    hydra.run

    if @hotels_content != nil && @hotels_availability != nil
      # Redirect to error page or sth
    end
  end

  def show
    @hotel_code = params[:id].split('-').pop.to_i

    destinations_file = File.read(Rails.root + "app/assets/jsons/destinations.json")
    @destinations = JSON.parse destinations_file

    signature = generate_signature
    availability_request_hash = generate_availability_request_hash(params)
    availability_request_hash.except! "destination"
    availability_request_hash["hotels"] = {
      hotel: [@hotel_code]
    }
    availability_request_hash["filter"] = {
      paymentType: "AT_WEB"
    }

    Rails.logger.info "Availability Hash #{JSON.generate(availability_request_hash)}"
    # content_request_hash = generate_content_request_hash(params)

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

    content_request = Typhoeus::Request.new(
      "https://api.test.hotelbeds.com/hotel-content-api/1.0/hotels/#{@hotel_code}",
      method: :get,
      # params: content_request_hash,
      headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => "4whec3tnzq9abhrx2ku9n78t", 'X-Signature' => signature }
    )
    content_request.on_complete do |response|
      if response.success?
        @hotel_content = JSON.parse response.body
        # Rails.logger.info "Hotels Content: #{response.body}"
      else
        # Rails.logger.info response.body.inspect
      end
    end

    hydra = Typhoeus::Hydra.hydra
    hydra.queue availability_request
    hydra.queue content_request
    hydra.run

    # respond_to do |format|
    #   format.html { render json: @hotel_availability }
    # end

    if @hotel_content != nil && @hotel_availability != nil
      # Redirect to error page or sth
    end

    # Reestructuring rates
    @hotel_availability['hotels']['hotels'][0]['rooms'].each do |room|
      new_rate_structure = Hash.new
      room['rates'].each do |rate|
        new_rate_structure[rate['boardCode']] = []
      end
      (1..params[:number_of_rooms].to_i).to_a.each_with_index do |room_number, room_index|
        adults = params["room_#{room_number}_adults"].to_i
        children = params["room_#{room_number}_children"].to_i
        room['rates'].each do |rate|
          if rate["adults"] == adults && rate["children"] == children
            children_ages = []
            if children.to_i > 0
              children_ages = rate["childrenAges"].split(",")
              (1..children).to_a.each do |child_number|
                children_ages.delete params["room_#{room_number}_child_#{child_number}_age"]
              end
            end
            if children_ages.empty?
              new_rate_structure[rate['boardCode']].push rate
            end
          end
        end
      end
      room['boards'] = new_rate_structure
    end

    # hotel_file = File.read(Rails.root + "app/assets/jsons/hotel_availability.json")
    # @hotel_availability = JSON.parse hotel_file

    # hotel_content_file = File.read(Rails.root + "app/assets/jsons/hotel_content.json")
    # @hotel_content = JSON.parse hotel_content_file
  end
end
