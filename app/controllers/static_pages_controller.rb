class StaticPagesController < ApplicationController
  # Skip authentication for the about page
  skip_before_action :authenticate_user!, only: :about

  def about
    if user_signed_in?
      redirect_to properties_path
    end
    # No logic needed for unauthenticated users; renders about page
  end
end