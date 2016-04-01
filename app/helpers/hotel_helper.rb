module HotelHelper
  def hotel_image(hotel)
    if hotel.has_key? "images"
      hotel["images"].each do |image|
        if image["imageTypeCode"] == "GEN" && image['order'] == 1
          return "http://photos.hotelbeds.com/giata/small/" + image["path"]
        end
      end
      return "http://photos.hotelbeds.com/giata/small/" + hotel["images"][0]["path"]
    end
    # Return default missing image
    return asset_path("logo-neander-travel.png")
  end

  def room_image(room_code, hotel_images)
    hotel_images.each do |image|
      if image['roomCode'] == room_code
        return "http://photos.hotelbeds.com/giata/small/" + image['path']
      end
    end
    return asset_path("logo-neander-travel.png")
  end

  def room_facilities(room_code, hotel_rooms)
    hotel_rooms.each do |room|
      if room['roomCode'] == room_code
        return room['roomFacilities']
      end
    end
  end

  def full_destination(country_code, destination_code, zone_code)
    destinations_file = File.read(Rails.root + "app/assets/jsons/destinations.json")
    destinations = JSON.parse destinations_file
    full_destination_string = ""

    destinations['destinations'].each do |destination|
      if destination['code'] == destination_code && destination['countryCode'] == country_code
        Rails.logger.info "#{destination['name']['content']}"
        if zone_code == nil
          full_destination_string = "#{destination['name']['content']}"
        else
          zone_code = zone_code.to_i
          destination['zones'].each do |zone|
            if zone['zoneCode'] == zone_code
              full_destination_string = "#{destination['name']['content']}, #{zone['name']}"
              break
            end
          end
        end
      end
      break if full_destination_string != ""
    end
    return full_destination_string
  end

  def hotel_link(hotel)
    return '/hotels/' + hotel["name"]["content"].parameterize + "-" + hotel["code"].to_s
  end

  def calculate_gross_room_rate(rate)
    if rate.has_key? 'hotelMandatory'
      rate_in_cents = rate['sellingRate'].to_f * 100
    else
      rate_in_cents = rate['net'].to_f * 100 # * 1.25
    end
    Rails.logger.info "Rate in cents: #{rate_in_cents.inspect}"

    discount_in_cents = 0.00
    if rate.has_key? 'offers'
      rate['offers'].each do |offer|
        discount_in_cents += offer['amount'].to_f * (-1) * 100
      end
    end
    Rails.logger.info "Discount in cents: #{discount_in_cents.inspect}"

    gross_rate_in_cents = rate_in_cents + discount_in_cents
    Rails.logger.info "Gross in cents: #{gross_rate_in_cents.inspect}"

    return { "gross" => gross_rate_in_cents / 100, "client_total" => rate_in_cents / 100 }
  end

end
