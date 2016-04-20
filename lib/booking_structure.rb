class BookingStructure
  def setParams(params)
    @params = params
  end

  def generate
    hash = Hash.new
    hash["holder"] = { name: @params[:holder_name], surname: @params[:holder_surname] }
    hash["rooms"] = [
      {
        rateKey: @params[:rateKey],
        paxes: []
      }
    ]
    pax_index = 0
    (1..@params[:number_of_rooms].to_i).to_a.each_with_index do |room_number, room_index|
      (1..@params["room_#{room_number}_adults"].to_i).to_a.each do |adult_number|
        hash["rooms"][0][:paxes][pax_index] = {
          roomId: room_number,
          type: "AD",
          age: @params["room_#{room_number}_adult_#{adult_number}_age"],
          name: @params["room_#{room_number}_adult_#{adult_number}_name"],
          surname: @params["room_#{room_number}_adult_#{adult_number}_surname"]
        }
        pax_index = pax_index + 1
      end
      if @params["room_#{room_number}_children"].to_i > 0
        (1..@params["room_#{room_number}_children"].to_i).to_a.each do |child_number|
          hash["rooms"][0][:paxes][pax_index] = {
            roomId: room_number,
            type: "CH",
            age: @params["room_#{room_number}_child_#{child_number}_age"],
            name: @params["room_#{room_number}_child_#{child_number}_name"],
            surname: @params["room_#{room_number}_child_#{child_number}_surname"]
          }
          pax_index = pax_index + 1
        end
      end
    end
    hash['clientReference'] = "Client Reference"

    # hash["paymentData"] = [{
    #   paymentCard: {
    #     cardType: @params[:card_type],
    #     cardNumber: @params[:card_number],
    #     expirityDate: @params[:card_expirity_month],
    #     cardCVC: @params[:card_cvc]
    #   },
    #   contactData: {
    #     email: @params[:holder_email],
    #     phoneNumber: @params[:holder_phone]
    #   }
    # }]
    return hash
  end
end
