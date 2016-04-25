class Admin::AdministratorsController < AdminController

  def index
    @admins = Administrator.all
  end

  def new
    @admin = Administrator.new
  end

  def create
    @admin = Administrator.new administrator_params
    if @admin.save
      redirect_to admin_administrators_path
    else
      render action: 'new'
    end
  end

  def edit
    @admin = Administrator.find params[:id]
  end

  def update
    if @admin.update administrator_params
      redirect_to admin_administrators_path
    else
      render action: 'edit'
    end
  end

  def destroy
    @admin.destroy
    redirect_to admin_administrators_path
  end

  private

    def administrator_params
      params.require(:administrator).permit(:name, :email, :password, :password_confirmation)
    end

end
