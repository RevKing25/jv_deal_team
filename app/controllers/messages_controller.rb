class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_parent_message, only: [:reply]

  def create
    @message = Message.new(message_params)
    @message.sender = current_user
    @message.property_id = params[:message][:property_id] if params[:message][:property_id].present?

    Rails.logger.debug "Message attributes before save: #{@message.attributes.inspect}"
    if @message.save
      Rails.logger.debug "Message saved successfully: #{@message.inspect}"
      redirect_to messages_user_path(current_user, with_user_id: @message.receiver_id), notice: 'Message sent successfully.'
    else
      Rails.logger.debug "Message failed to save: #{@message.errors.full_messages}"
      redirect_to messages_user_path(current_user), alert: 'Failed to send message.'
    end
  end

  def reply
    @reply = Message.new(parent_message: @parent_message)
    @reply.sender = current_user
    @reply.receiver = @parent_message.sender
    @reply.property = @parent_message.property

    Rails.logger.debug "Reply attributes before save: #{@reply.attributes.inspect}"
    if @reply.update(message_params)
      Rails.logger.debug "Reply saved successfully: #{@reply.inspect}"
      redirect_to messages_user_path(current_user, with_user_id: @reply.receiver_id), notice: 'Reply sent successfully.'
    else
      Rails.logger.debug "Reply failed to save: #{@reply.errors.full_messages}"
      redirect_to messages_user_path(current_user), alert: 'Failed to send reply.'
    end
  end

  private

  def set_parent_message
    @parent_message = Message.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:content, :receiver_id, :parent_message_id, :property_id)
  end
end