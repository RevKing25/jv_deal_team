class PropertiesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_property, only: [:show, :edit, :update, :destroy_image]
  before_action :authorize_user, only: [:edit, :update, :destroy_image]

  def index
    # Base scope is only active properties
    @properties = Property.active
    if params[:state].present? && Property::US_STATES.map(&:last).include?(params[:state])
      @properties = @properties.where(state: params[:state])
    end
    # No else needed; @properties is already set to active scope
  end

  def show
    # Allow owner to see expired property, others see only active
    unless @property.active? || (user_signed_in? && @property.user == current_user)
      redirect_to properties_path, alert: "That property is no longer available."
    end
  end

  def new
    @property = current_user.properties.build
  end

  def create
    @property = current_user.properties.build(property_params)
    if @property.save
      redirect_to @property, notice: "Property was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if params[:property][:images].present?
      # Append new images to existing ones
      new_images = params[:property][:images].reject(&:blank?)
      @property.images = @property.images + new_images.map { |img| PropertyImageUploader.new(@property, :images).tap { |u| u.cache!(img) } }
    end
    # Update other attributes
    if @property.update(property_params.except(:images))
      redirect_to @property, notice: "Property was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy_image
    index = params[:image_index].to_i
    image = @property.images[index]
    if image.present?
      image.remove!  # CarrierWave removes the specific file
      @property.images.delete_at(index)
      @property.save
    end
    redirect_to edit_property_path(@property), notice: "Image was successfully deleted."
  end

  private

  def set_property
    @property = Property.find(params[:id])
  end

  def authorize_user
    redirect_to root_path, alert: "Not authorized." unless @property.user == current_user
  end

  def property_params
    params.require(:property).permit(:title, :description, :price, :street_address, :city, :state, :remove_contract_file, :zip_code, :contract_file, :expiration_date, images: [])
  end
end