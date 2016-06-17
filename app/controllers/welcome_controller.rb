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
    render text: "C1e3XhAIk_jfgWe1qxNC6J-r_83yR2GAFYfju5d_NT0.2EdrOjgOoZdLN7d_2JUHU0C_vatKPkygTLwqRfGQtz4"
  end
end
