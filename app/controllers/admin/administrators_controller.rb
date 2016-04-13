class Admin::AdministratorsController < AdminController

  def index
    @admins = Administrator.all
  end

end
