class HotelsController < ApplicationController

  include HotelHelper
  include BookingForm

  def index
    @country_code, @destination_code, @zone_code = params['destination'].split '-'

    destinations_file = File.read(Rails.root + "app/assets/jsons/destinations.json")
    @destinations = JSON.parse destinations_file

    signature = generate_signature
    content_request_hash = generate_content_request_hash(params)

    content_request = Typhoeus::Request.new(
      "#{ENV['HB_CONTENT_API_END_POINT']}/#{ENV['HB_CONTENT_API_VERSION']}/hotels",
      method: :get,
      params: content_request_hash,
      accept_encoding: "gzip",
      headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => ENV['HB_KEY'], 'X-Signature' => signature }
    )
    content_request.run
    content_response = content_request.response
    if content_response.success?
      @hotels_content = JSON.parse content_response.body
      # Rails.logger.info "Hotels Content: #{content_response.body}"
      # Rails.logger.info "Hotels Content: #{@hotels_content.inspect}"
    else
      Rails.logger.info content_response.body
    end

    availability_request_hash = generate_availability_request_hash(params)
    availability_request_hash["hotels"] = {
      hotel: @hotels_content["hotels"].map { |e| e['code'] }
    }

    # Rails.logger.info "Availability Hash #{JSON.generate(availability_request_hash)}"

    availability_request = Typhoeus::Request.new(
      "#{ENV['HB_BOOKING_API_END_POINT']}/#{ENV['HB_BOOKING_API_VERSION']}/hotels",
      method: :post,
      body: JSON.generate(availability_request_hash),
      accept_encoding: "gzip",
      headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => ENV['HB_KEY'], 'X-Signature' => signature }
    )
    availability_request.run
    availability_response = availability_request.response
    if availability_response.success?
      @hotels_availability = JSON.parse availability_response.body
      # Rails.logger.info "Hotels Availability: #{availability_response.body}"
    else
      Rails.logger.info availability_response.body
    end

    # hydra = Typhoeus::Hydra.hydra
    # hydra.queue availability_request
    # hydra.queue content_request
    # hydra.run

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

    # Rails.logger.info "Availability Hash #{JSON.generate(availability_request_hash)}"
    # content_request_hash = generate_content_request_hash(params)

    availability_request = Typhoeus::Request.new(
      "#{ENV['HB_BOOKING_API_END_POINT']}/#{ENV['HB_BOOKING_API_VERSION']}/hotels",
      method: :post,
      body: JSON.generate(availability_request_hash),
      accept_encoding: "gzip",
      headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => ENV['HB_KEY'], 'X-Signature' => signature }
    )
    availability_request.on_complete do |response|
      if response.success?
        @hotel_availability = JSON.parse response.body
        # Rails.logger.info "Hotels Availability: #{response.body}"
      else
        Rails.logger.info response.body.inspect
      end
    end

    content_request = Typhoeus::Request.new(
      "#{ENV['HB_CONTENT_API_END_POINT']}/#{ENV['HB_CONTENT_API_VERSION']}/hotels/#{@hotel_code}?language=CAS",
      method: :get,
      # params: content_request_hash,
      accept_encoding: "gzip",
      headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => ENV['HB_KEY'], 'X-Signature' => signature }
    )
    content_request.on_complete do |response|
      if response.success?
        @hotel_content = JSON.parse response.body
        # Rails.logger.info "Hotels Content: #{response.body}"
      else
        Rails.logger.info response.body
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
          # Rails.logger.info "Rate: #{rate.inspect}"
          if rate["adults"] == adults && rate["children"] == children
            children_ages = []
            if children.to_i > 0
              children_ages = rate["childrenAges"].split(",")
              (1..children).to_a.each do |child_number|
                children_ages.delete params["room_#{room_number}_child_#{child_number}_age"]
              end
            end
            if children_ages.empty?
              new_rate_structure[rate['boardCode']][room_index] = rate
            end
          end
        end
      end
      keys = new_rate_structure.keys
      keys.each do |key|
        new_rate_structure[key].reject! { |c| c == nil }
        if new_rate_structure[key].length < params[:number_of_rooms].to_i
          new_rate_structure.delete key
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
