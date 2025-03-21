# app/controllers/users/connections_controller.rb
class Users::ConnectionsController < ApplicationController
  before_action :authenticate_user!

  def create
    @connection = current_user.sent_connections.build(receiver_id: params[:user_id], status: :pending)
    if @connection.save
      redirect_to user_path(params[:user_id]), notice: "Connection request sent!"
    else
      redirect_to user_path(params[:user_id]), alert: @connection.errors.full_messages.join(", ")
    end
  end

  def index
    @pending_connections = current_user.received_connections.pending
    @current_connections = current_user.all_connected_users
  end

  def update
  Rails.logger.info "Before update: current_user.pending_connections_count = #{current_user.pending_connections_count}"
  @connection = Connection.find(params[:id])
  if @connection.receiver == current_user && @connection.update(connection_params)
    current_user.reload
    warden.set_user(current_user) # Ensure session update
    Rails.logger.info "After reload: current_user.pending_connections_count = #{current_user.pending_connections_count}"
    redirect_to user_connections_path(current_user, cache_buster: Time.now.to_i), notice: "Connection #{@connection.status}.", data: { turbo: false }
  else
    Rails.logger.info "Update failed: #{@connection.errors.full_messages}"
    redirect_to user_connections_path(current_user), alert: "Failed to update connection.", data: { turbo: false }
  end
end



  private

  def connection_params
    params.require(:connection).permit(:status)
  end
end