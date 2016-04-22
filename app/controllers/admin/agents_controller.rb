class Admin::AgentsController < AdminController

  def index
    @agents = Agent.all
  end

  def new
    @agent = Agent.new
  end

end
