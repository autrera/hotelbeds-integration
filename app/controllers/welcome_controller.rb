class WelcomeController < ApplicationController

  include HotelHelper

  def index
    destinations_file = File.read(Rails.root + "app/assets/jsons/destinations.json")
    @destinations = JSON.parse destinations_file

    boards_file = File.read(Rails.root + "app/assets/jsons/boards.json")
    @boards = JSON.parse boards_file
  end

  def not_found
  end

  def letsencrypt
    render text: "PnXdZP4BiosN46uqk7GZ1WLlpLW6zmVs2dKjiTov3ec.2EdrOjgOoZdLN7d_2JUHU0C_vatKPkygTLwqRfGQtz4"
  end
end
