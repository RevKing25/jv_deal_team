class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @interested_properties = current_user.interested_properties
  end
end