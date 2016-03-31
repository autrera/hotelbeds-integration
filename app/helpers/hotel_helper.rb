module HotelHelper
  def hotel_image(hotel)
    if hotel.has_key? "images"
      hotel["images"].each do |image|
        if image["imageTypeCode"] == "GEN"
          return "http://photos.hotelbeds.com/giata/" + image["path"]
        end
      end
      return "http://photos.hotelbeds.com/giata/" + hotel["images"][0]["path"]
    end
    # Return default missing image
    return asset_path("logo-neander-travel.png")
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

end
