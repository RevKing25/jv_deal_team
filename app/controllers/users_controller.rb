class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_property, only: [:destroy]
  before_action :set_user, only: [:show, :messages]  # Added :messages to use set_user

  def show
    @properties = @user.properties
    # Retrieve top-level messages (parent_message_id: nil) OR direct replies received by the user
    @messages_with_replies = @user.received_messages.where("(parent_message_id IS NULL OR parent_message_id IS NOT NULL) AND receiver_id = ?", @user.id).order(created_at: :desc)
    # Sent messages (top-level only) to show conversations initiated by the user
    @sent_messages_with_replies = @user.sent_messages.where(parent_message_id: nil).order(created_at: :desc)

        # Load pending received connections if viewing own profile
    @pending_connections = @user == current_user ? current_user.received_connections.pending : []
    
    # Mark messages as read if viewing own profile
    if user_signed_in? && @user == current_user
      @messages_with_replies.where(read: false).each(&:mark_as_read)
    end
  end

  
  def index
    @users = User.all
    if params[:search].present?
      @users = @users.where("name ILIKE ?", "%#{params[:search]}%")
    end
    if params[:state].present?
      @users = @users.where(state: params[:state])  # Filter by single state column
    end
    @states = Property::US_STATES  # For the filter dropdown
  end

  def messages
    @conversation_partners = @user.conversation_partners
    @selected_user = params[:with_user_id] ? User.find(params[:with_user_id]) : @conversation_partners.first
    if @selected_user
      @messages = @user.messages_with(@selected_user)
      # Log the first message's property for debugging
      first_property = @messages.first&.property
      Rails.logger.debug "First message property: #{first_property.inspect}"
      # Mark received messages as read
      @messages.where(receiver: @user, read: false).each(&:mark_as_read)
    else
      @messages = []
    end
  end

  def destroy
    if @property.user == current_user
      @property.destroy
      redirect_to user_path(current_user), notice: 'Property was successfully deleted.'
    else
      redirect_to user_path(current_user), alert: 'Not authorized to delete this property.'
    end
  end

  private

  def set_user
    if params[:id]
      begin
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        Rails.logger.error "User not found for ID: #{params[:id]}"
        redirect_to root_path, alert: "User not found."
        return
      end
    else
      @user = current_user
    end
  end

  def set_property
    @property = Property.find(params[:id])
  end
end