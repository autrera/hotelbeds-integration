require 'mail'
class ClientMailer < ActionMailer::Base

  def login_credentials(client, password)
    @client = client
    @password = password
    mail subject: "Neandertravel.com | Notificacion de Registro",
         to: client.email,
         from: "no-reply@neandertravel.com"
  end

end
