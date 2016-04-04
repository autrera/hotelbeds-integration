class WelcomeController < ApplicationController

  include HotelHelper

  layout false

  def index
    destinations_file = File.read(Rails.root + "app/assets/jsons/destinations.json")
    @destinations = JSON.parse destinations_file

    boards_file = File.read(Rails.root + "app/assets/jsons/boards.json")
    @boards = JSON.parse boards_file
  end
end
