# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :authorize_user!, only: %i[edit update destroy]
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
    @event = current_user.events.build(params.require(:event).permit(:event_name, :location, :price, :date, :capacity,
                                                                     :description, :image))
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

    if current_user.approved?
      if @event.registered_users.include?(current_user)
        flash[:notice] = 'You have already registered for this event.'
      else
        @event.registered_users << current_user
        flash[:success] = 'Successfully registered!'
      end
    else
      flash[:alert] = 'You must be approved to register.'
    end

    redirect_to @event
  end

  def unregister
    @event = Event.find(params[:id])

    if @event.registered_users.include?(current_user)
      @event.registered_users.delete(current_user)
      flash[:notice] = 'You have been unregistered from the event.'
    else
      flash[:alert] = 'You are not registered for this event.'
    end

    redirect_to @event
  end

  before_action :check_approval, only: %i[show new edit create update destroy register unregister]

  def check_approval
    unless user_signed_in?
      redirect_to events_path, alert: 'You must log in to create events!'
      return
    end

    return if current_user.approved?

    redirect_to root_path, alert: 'You must be approved to view this event.'
  end

  private

  def authorize_user!
    @event = Event.find(params[:id])
    return if @event.user == current_user

    flash[:alert] = 'You are not authorized to modify this event.'
    redirect_to events_path
  end
end
