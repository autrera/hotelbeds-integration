class Administrator < ActiveRecord::Base

  default_scope {
    order id: :asc
  }

  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
end
