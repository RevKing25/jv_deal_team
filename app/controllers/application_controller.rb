class ApplicationController < ActionController::Base
  # Devise: Redirect after sign-out
  def after_sign_out_path_for(resource)
    root_path
  end
end