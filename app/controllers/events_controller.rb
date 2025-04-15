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
end
