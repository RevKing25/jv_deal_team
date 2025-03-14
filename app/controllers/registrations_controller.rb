class RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!
  before_action :ensure_current_user, only: [:edit, :update]
  before_action :configure_permitted_parameters, if: :devise_controller?

  def edit
    super
  end

  def update
    Rails.logger.debug "Params received: #{params.inspect}"
    Rails.logger.debug "Before update - profile_photo: #{resource.profile_photo}"
    if super
      Rails.logger.debug "After update - profile_photo: #{resource.profile_photo}"
    else
      Rails.logger.debug "Update failed - errors: #{resource.errors.full_messages}"
    end
  end

  private

  def ensure_current_user
    unless resource == current_user
      redirect_to root_path, alert: "You are not authorized to edit this profile."
    end
  end

  def configure_permitted_parameters
    Rails.logger.debug "Configuring permitted parameters"
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :name, :profile_photo])
    devise_parameter_sanitizer.permit(:account_update, keys: [:email, :name, :profile_photo, :password, :password_confirmation, :current_password])
  end
end