class Admin::ClientsController < AdminController

  def index
    @clients = Client.all
  end

end
