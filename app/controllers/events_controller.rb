# frozen_string_literal: true

class EventsController < ApplicationController
  def index
    @events = Event.order(:date)
    render :index
  end

  def show
    @event = Event.find(params[:id])
    render :show
  end

  def new
    @event = Event.new
    render :new
  end

  def edit
    @event = Event.find(params[:id])
    render :edit
  end

  def create
    @event = Event.new(params.require(:event).permit(:event_name, :location, :price, :date, :capacity, :description,
                                                     :image))
    if @event.save
      flash[:success] = 'New event successfully created!'
      redirect_to events_url
    else
      flash.now[:error] = 'Event creation failed.'
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @event = Event.find(params[:id])
    if @event.update(params.require(:event).permit(:event_name, :location, :price, :date, :capacity, :description,
                                                   :image))
      flash[:success] = 'Event successfully updated!'
      redirect_to event_url(@event)
    else
      flash.now[:error] = 'Event update failed'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    flash[:success] = 'The event was successfully deleted.'
    redirect_to events_url, status: :see_other
  end

  def register
    @event = Event.find(params[:id])

    if current_user
      @event.registered_users << current_user.username unless @event.registered_users.include?(current_user.username)

      if @event.save
        flash[:success] = 'You have successfulyl registered for this event!'
        redirect_to @event
      else
        flash[:error] = 'There was an issue with your registration.'
        redirect_to @event
      end
    else
      flash[:error] = 'You must be logged in to register.'
      redirect_to login_path
    end
  end
end
