class AdminController < ActionController::Base

  protect_from_forgery with: :exception

  before_action :authenticate_admin_administrator!
  # before_action :set_sidebar_partial

  layout 'dashboard'
end
