class AgentController < ActionController::Base

  protect_from_forgery with: :exception

  before_action :authenticate_agent_agent!
  # before_action :set_sidebar_partial

  layout 'dashboard'
end
