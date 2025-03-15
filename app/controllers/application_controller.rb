  class ApplicationController < ActionController::Base
  # Ensure Devise's authenticate_user! is available
  before_action :authenticate_user!, unless: :devise_controller?

  # Optional custom override (only if you need custom behavior)
  def authenticate_user!
    return if user_signed_in?
    redirect_to new_user_session_path, alert: "Please sign in to access this page."
  end
end

  def after_sign_in_path_for(resource)
    properties_path
  end
 # Devise: Redirect after sign-out
  def after_sign_out_path_for(resource)
    root_path
  end
