class Reservation < ActiveRecord::Base

  belongs_to :client

  serialize :rooms
  serialize :supplier

end
