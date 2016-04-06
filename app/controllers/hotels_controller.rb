class HotelsController < ApplicationController

  include HotelHelper

  def index
    @country_code, @destination_code, @zone_code = params['destination'].split '-'

    destinations_file = File.read(Rails.root + "app/assets/jsons/destinations.json")
    @destinations = JSON.parse destinations_file

    hotels_file = File.read(Rails.root + "app/assets/jsons/hotels_content.json")
    @hotels = JSON.parse hotels_file

    hotels_availability_file = File.read(Rails.root + "app/assets/jsons/hotels_availability.json")
    @hotels_availability = JSON.parse hotels_availability_file

    # hotels_content_file = File.read(Rails.root + "app/assets/jsons/hotels_content.json")
    # @hotels_content = JSON.parse hotels_file

    # signature = Digest::SHA256.hexdigest "4whec3tnzq9abhrx2ku9n78t" + "bS6CCG3tkc" + Time.now.to_i.to_s
    # body = {
    #   stay: {
    #     checkIn: "2016-06-08",
    #     checkOut: "2016-06-10",
    #     shiftDays: "2"
    #   },
    #   occupancies: [
    #     {
    #       rooms: 1,
    #       adults: 2,
    #       children: 2,
    #       paxes: [
    #         {
    #          type: "AD",
    #          age: 30
    #         },
    #         {
    #          type: "AD",
    #          age: 30
    #         },
    #         {
    #          type: "CH",
    #          age: 8
    #         },
    #         {
    #          type: "CH",
    #          age: 8
    #         }
    #      ]
    #     },
    #     {
    #       rooms: 1,
    #       adults: 1,
    #       children: 1,
    #       paxes: [
    #         {
    #          type: "AD",
    #          age: 30
    #         },
    #         {
    #          type: "CH",
    #          age: 8
    #         }
    #       ]
    #     }
    #   ],
    #   destination: {
    #     code: destination_code,
    #     zone: zone_code
    #   }
    # }
    # request = Typhoeus::Request.new(
    #   "https://api.test.hotelbeds.com/hotel-api/1.0/hotels",
    #   method: :post,
    #   body: JSON.generate(body),
    #   headers: { 'Accept' => "application/json", 'Content-Type' => "application/json", 'Api-Key' => "4whec3tnzq9abhrx2ku9n78t", 'X-Signature' => signature }
    # )
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
