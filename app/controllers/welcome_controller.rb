class WelcomeController < ApplicationController
  def index
    destinations_file = File.read(Rails.root + "app/assets/jsons/destinations.json")
    @destinations = JSON.parse destinations_file
  end
end
