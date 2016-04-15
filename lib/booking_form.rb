module BookingForm

  def generate_signature
    signature = Digest::SHA256.hexdigest "4whec3tnzq9abhrx2ku9n78t" + "bS6CCG3tkc" + Time.now.to_i.to_s
    return signature
  end

  def generate_content_request_hash(params)
    country_code, destination_code, zone_code = params['destination'].split '-'

    hash = Hash.new
    hash = {
      fields: "all",
      destinationCode: destination_code,
      countryCode: country_code,
      from: 1,
      to: 1000
    }

    return hash
  end

  def generate_availability_request_hash(params)
    check_in  = Date.strptime(params[:check_in],  "%m/%d/%Y")
    check_out = check_in + (params[:number_of_nights].to_i)

    hash = Hash.new
    hash["stay"] = {
      checkIn:  check_in.strftime("%Y-%m-%d"),
      checkOut: check_out.strftime("%Y-%m-%d")
    }
    hash["occupancies"] = []

    (1..params[:number_of_rooms].to_i).to_a.each_with_index do |room_number, room_index|

      hash["occupancies"][room_index] = {
        rooms: 1,
        adults: params["room_#{room_number}_adults"].to_i,
        children: params["room_#{room_number}_children"].to_i,
        paxes: []
      }

      pax_index = 0
      (1..params["room_#{room_number}_adults"].to_i).to_a.each do |adult_number|
        hash["occupancies"][room_index][:paxes][pax_index] = {
          type: "AD"
        }
        pax_index = pax_index + 1
      end

      if params["room_#{room_number}_children"].to_i > 0
        (1..params["room_#{room_number}_children"].to_i).to_a.each do |child_number|
          hash["occupancies"][room_index][:paxes][pax_index] = {
            type: "CH",
            age: params["room_#{room_number}_child_#{child_number}_age"]
          }
          pax_index = pax_index + 1
        end
      end
    end

    country_code, destination_code, zone_code = params['destination'].split '-'

    if zone_code != nil
      hash["destination"] = {
        code: destination_code,
        zone: zone_code
      }
    else
      hash["destination"] = {
        code: destination_code
      }
    end

    return hash
  end

end
