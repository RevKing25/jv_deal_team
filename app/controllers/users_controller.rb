class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_property, only: [:destroy]
  before_action :set_user, only: [:show, :messages, :create_message]

  def show
    @properties = @user.properties
    @messages_with_replies = @user.received_messages.where("(parent_message_id IS NULL OR parent_message_id IS NOT NULL) AND receiver_id = ?", @user.id).order(created_at: :desc)
    @sent_messages_with_replies = @user.sent_messages.where(parent_message_id: nil).order(created_at: :desc)
    @pending_connections = @user == current_user ? current_user.received_connections.pending : []
    
    # Messaging form for connected users
    if user_signed_in? && @user != current_user
      Rails.logger.info "Checking connection: current_user=#{current_user.id}, profile_user=#{@user.id}"
      is_connected = current_user.connected_with?(@user)
      Rails.logger.info "Connected? #{is_connected}"
      @message = Message.new if is_connected
    end

    if user_signed_in? && @user == current_user
      @messages_with_replies.where(read: false).each(&:mark_as_read)
    end
  end

  def edit
    # @user is set by set_user; renders edit.html.erb by default
  end

  def update
    Rails.logger.info "Update params: #{params.inspect}"
    if @user.update(user_params)
      Rails.logger.info "User updated successfully: #{@user.profile_picture}"
      redirect_to user_path(@user), notice: "Profile updated successfully."
    else
      Rails.logger.info "Update failed: #{@user.errors.full_messages}"
      render :edit, status: :unprocessable_entity
    end
  end


  def index
    @users = User.all
    if params[:search].present?
      @users = @users.where("name ILIKE ?", "%#{params[:search]}%")
    end
    if params[:state].present?
      @users = @users.where(state: params[:state])
    end
    if params[:role].present?
      @users = @users.where(role: params[:role])
    end
    @states = Property::US_STATES
  end

  def messages
    @conversation_partners = @user.conversation_partners
    @selected_user = params[:with_user_id] ? User.find(params[:with_user_id]) : @conversation_partners.first
    if @selected_user
      @messages = @user.messages_with(@selected_user)
      @messages.where(receiver: @user, read: false).each(&:mark_as_read)
    else
      @messages = []
    end
  end

  def create_message
    Rails.logger.info "Create message attempt: sender=#{current_user.id}, receiver=#{@user.id}"
    if current_user.connected_with?(@user)
      # Create message without a property association
      @message = Message.new(message_params.merge(sender: current_user, receiver: @user))
      if @message.save
        Rails.logger.info "Message saved: #{@message.id}"
        redirect_to user_path(@user), notice: "Message sent!"
      else
        Rails.logger.info "Message failed: #{@message.errors.full_messages}"
        @properties = @user.properties
        @messages_with_replies = @user.received_messages.where("(parent_message_id IS NULL OR parent_message_id IS NOT NULL) AND receiver_id = ?", @user.id).order(created_at: :desc)
        @sent_messages_with_replies = @user.sent_messages.where(parent_message_id: nil).order(created_at: :desc)
        @pending_connections = @user == current_user ? current_user.received_connections.pending : []
        render :show, status: :unprocessable_entity
      end
    else
      Rails.logger.info "Not connected, redirecting"
      redirect_to user_path(@user), alert: "You must be connected to message this user."
    end
  end

  def destroy
    if @property.user == current_user
      @property.destroy
      redirect_to user_path(current_user), notice: "Property was successfully deleted."
    else
      redirect_to user_path(current_user), alert: "Not authorized to delete this property."
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

  def message_params
    params.require(:message).permit(:content)
  end
end