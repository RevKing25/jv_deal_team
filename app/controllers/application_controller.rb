  class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception


  # Ensure Devise's authenticate_user! is available
  before_action :authenticate_user!, unless: :devise_controller?

  # Optional custom override (only if you need custom behavior)
  #def authenticate_user!
    #return if user_signed_in?
    #redirect_to new_user_session_path, alert: "Please sign in to access this page."
  #end
#end
  
# Override Devise's after_sign_in_path_for
   def after_sign_in_path_for(resource)
    user_path(resource)  # Just redirect to profile, no flash needed
  end

 
 # Devise: Redirect after sign-out
  def after_sign_out_path_for(resource)
    root_path
  end

  private

  def refresh_current_user
    warden.set_user(current_user.reload) if user_signed_in?
  end
  end