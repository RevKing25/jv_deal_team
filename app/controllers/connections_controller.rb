class ConnectionsController < ApplicationController
  before_action :authenticate_user!

 
  def create
    @connection = current_user.sent_connections.build(receiver_id: params[:user_id], status: :pending)
    if @connection.save
      redirect_to user_path(params[:user_id]), notice: "Connection request sent!"
    else
      redirect_to user_path(params[:user_id]), alert: @connection.errors.full_messages.join(", ")
    end
  end

  def update
    @connection = Connection.find(params[:id])
    if @connection.receiver == current_user && @connection.pending?
      @connection.update(status: params[:status])
      redirect_to user_path(current_user), notice: "Connection #{params[:status]}!"
    else
      redirect_to user_path(current_user), alert: "Cannot update this connection."
    end
  end

  private

  def connection_params
    params.require(:connection).permit(:receiver_id, :status)
  end
end
