class StaticPagesController < ApplicationController
  # Skip authentication for the about page
  skip_before_action :authenticate_user!, only: [:about]

  def about
    # No logic needed for a static page
  end
end