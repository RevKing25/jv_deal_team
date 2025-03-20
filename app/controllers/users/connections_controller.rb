class Users::ConnectionsController < ApplicationController
  before_action :authenticate_user!
  # Remove set_user from index since we’ll use current_user directly

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
    @current_connections = current_user.all_connected_users.order(:name)
  end

  def update
    @connection = Connection.find(params[:id])
    if @connection.receiver == current_user && @connection.update(connection_params)
      redirect_to user_connections_path(current_user), notice: "Connection #{@connection.status}."
    else
      redirect_to user_connections_path(current_user), alert: "Failed to update connection."
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def connection_params
    params.require(:connection).permit(:status)
  end
end