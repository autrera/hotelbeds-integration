class Admin::AgentsController < AdminController

  def index
    @agents = Agent.all
  end

  def new
    @agent = Agent.new
  end

  def create
    @agent = Agent.new agent_params
    if @agent.save
      redirect_to admin_agents_path
    else
      render action: 'new'
    end
  end

  def edit
    @agent = Agent.find params[:id]
  end

  def update
    if @agent.update agent_params
      redirect_to admin_agents_path
    else
      render action: 'edit'
    end
  end

  def destroy
    @agent.destroy
    redirect_to admin_agents_path
  end

  private

    def agent_params
      params.require(:agent).permit(:name, :surname, :email, :password, :password_confirmation)
    end

end
