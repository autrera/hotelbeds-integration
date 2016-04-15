class ClientController < ActionController::Base

  protect_from_forgery with: :exception

  before_action :authenticate_client_client!
  # before_action :set_sidebar_partial

  layout 'dashboard'
end
