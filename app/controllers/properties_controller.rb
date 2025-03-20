class PropertiesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_property, only: [:show, :edit, :update, :destroy_image, :create_message]  # Add :create_message
  before_action :authorize_user, only: [:edit, :update, :destroy_image]

  def index
    @properties = Property.active
    if params[:state].present? && Property::US_STATES.map(&:last).include?(params[:state])
      @properties = @properties.where(state: params[:state])
    end
  end

  def show
    # Allow owner to see expired property, others see only active
    unless @property.active? || (user_signed_in? && @property.user == current_user)
      redirect_to properties_path, alert: "That property is no longer available."
    else
      # Set up messaging form for interested or connected users
      if user_signed_in? && @property.user != current_user
        @interested = current_user.interested_properties.include?(@property)
        @connected = current_user.connected_with?(@property.user)
        @message = Message.new if @interested || @connected
      end
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

  def create_message
    if current_user.interested_properties.include?(@property) || current_user.connected_with?(@property.user)
      @message = Message.new(message_params.merge(sender: current_user, receiver: @property.user, property: @property))
      if @message.save
        redirect_to @property, notice: "Message sent!"
      else
        render :show, status: :unprocessable_entity, alert: "Failed to send message: #{@message.errors.full_messages.join(', ')}"
      end
    else
      redirect_to @property, alert: "You must express interest or be connected to message this user."
    end
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

  def message_params
    params.require(:message).permit(:content)
  end
end