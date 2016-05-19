require 'mail'
class ReservationMailer < ActionMailer::Base

  def client_confirmation(client_email, reservation, hotel_content, client_total)
    @reservation = reservation
    @hotel_content = hotel_content
    @client_total = client_total
    mail subject: "Neandertravel.com | Reservación ##{reservation['reference']}",
         to: client_email,
         from: "no-reply@neandertravel.com"
  end

end
