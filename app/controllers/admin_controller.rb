class AdminController < ActionController::Base

  protect_from_forgery with: :exception

  before_action :authenticate_admin_administrator!
  # before_action :set_sidebar_partial

  layout 'dashboard'

  def after_sign_in_path_for(resource)
    current_admin_administrator_path
  end
end
