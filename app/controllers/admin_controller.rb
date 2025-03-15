class AdminController < ApplicationController
  before_action :require_admin

  def dashboard
    @users = User.all
    @properties = Property.all
  end

  def destroy_user
    @user = User.find(params[:id])
    @user.destroy
    redirect_to admin_dashboard_path, notice: "User was successfully removed."
  end

  def destroy_property
    @property = Property.find(params[:id])
    @property.destroy
    redirect_to admin_dashboard_path, notice: "Property was successfully removed."
  end

  private

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
