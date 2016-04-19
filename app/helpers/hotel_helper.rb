module HotelHelper
  def hotel_image(hotel)
    if hotel.has_key? "images"
      hotel["images"].each do |image|
        if image["imageTypeCode"] == "GEN" && image['order'] == 1
          return "http://photos.hotelbeds.com/giata/" + image["path"]
        end
      end
      return "http://photos.hotelbeds.com/giata/" + hotel["images"][0]["path"]
    end
    # Return default missing image
    return asset_path("logo-neander-travel.png")
  end

  def room_image(room_code, hotel_images)
    hotel_images.each do |image|
      if image['roomCode'] == room_code
        return "http://photos.hotelbeds.com/giata/" + image['path']
      end
    end
    return asset_path("logo-neander-travel.png")
  end

  def find_room_facilities(room_code, hotel_rooms)
    if hotel_rooms != nil
      hotel_rooms.each do |room|
        if room['roomCode'] == room_code
          return room['roomFacilities']
        end
      end
    end
    return []
  end

  def full_destination(country_code, destination_code, zone_code)
    destinations_file = File.read(Rails.root + "app/assets/jsons/destinations.json")
    destinations = JSON.parse destinations_file
    full_destination_string = ""

    destinations['destinations'].each do |destination|
      if destination['code'] == destination_code && destination['countryCode'] == country_code
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
      # rate_in_cents = rate['sellingRate'].to_f * 100
      rate_in_cents = Monetize.parse(rate['sellingRate'])
    else
      # rate_in_cents = rate['net'].to_f * 100 # * 1.25
      rate_in_cents = Monetize.parse(rate['net']) # * 1.25
    end

    discount_in_cents = Money.new(0, "USD")
    if rate.has_key? 'offers'
      rate['offers'].each do |offer|
        # discount_in_cents += offer['amount'].to_f * (-1) * 100
        discount_in_cents += Monetize.parse(offer['amount'].delete("-"))
      end
    end

    gross_rate_in_cents = rate_in_cents + discount_in_cents

    return { "gross" => gross_rate_in_cents, "client_total" => rate_in_cents }
  end

  def group_facilities(facilities)
    factor = (facilities.length.to_f / 4).ceil
    grouped_facilities = []
    grouped_facilities[0] = facilities[0..(factor - 1)]
    grouped_facilities[1] = facilities[factor..(2 * factor - 1)]
    grouped_facilities[2] = facilities[(2 * factor)..(3 * factor - 1)]
    grouped_facilities[3] = facilities[(3 * factor)..facilities.length]

    return grouped_facilities
  end

  def group_items(items)
    factor = (items.length.to_f / 3).ceil
    grouped_items = []
    grouped_items[0] = items[0..(factor - 1)]
    grouped_items[1] = items[factor..(2 * factor - 1)]
    # grouped_items[2] = items[(2 * factor)..(3 * factor - 1)]
    grouped_items[2] = items[(2 * factor)..items.length]

    return grouped_items
  end

  def extract_hotel_availability(hotel_code, hotels_availability_list)
    hotels_availability_list.each do |hotel_availability|
      if hotel_availability['code'] == hotel_code
        return hotel_availability
      end
    end
    return nil
  end

end
