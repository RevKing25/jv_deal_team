class InterestsController < ApplicationController
  before_action :authenticate_user!

  def create
    @property = Property.find(params[:property_id])
    @interest = current_user.interests.build(property: @property)

    if @interest.save
      redirect_to request.referer || property_path(@property), notice: 'You have expressed interest in this property and can now view full details.'
    else
      redirect_to request.referer || property_path(@property), alert: @interest.errors.full_messages.join(', ')
    end
  end
end