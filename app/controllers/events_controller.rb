# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :authorize_user!, only: %i[edit update destroy]
  def index
    @events = Event.order(:date)
    render :index
  end

  def show
    @event = Event.find_by(id: params[:id])
    if @event.nil?
      flash[:alert] = 'Event not found.'
      redirect_to events_path
    else
      @message = Message.new
      @messages = @event.messages.includes(:sender).order(created_at: :asc)
      render :show
    end
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
    @event = current_user.events.build(event_params)

    if @event.save
      redirect_to @event, notice: 'Event was successfully created.'
    else
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
    begin
      @event = Event.find(params[:id])
      # Notify all registered users
      @event.registered_users.each do |user|
        Notification.create!(
          recipient: user,
          actor: current_user,
          action: 'deleted an event you registered for',
          notifiable: @event
        )
      end
      @event.destroy
      flash[:success] = 'The event was successfully deleted.'
      redirect_to events_url, status: :see_other
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = 'Event not found.'
      redirect_to events_url
    end
  end

  def register
    @event = Event.find(params[:id])

    if current_user.approved?
      if @event.registered_users.include?(current_user)
        flash[:notice] = 'You have already registered for this event.'
      else
        @event.registered_users << current_user
        flash[:notice] = 'Successfully registered for the event!'

        # Create a notification for the event creator
        if @event.user != current_user  # Ensure creator is not the same as the registrant
          Notification.create!(
            recipient: @event.user,  # Event creator
            actor: current_user,     # User registering
            action: 'registered for your event',
            notifiable: @event
          )
        end
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

      # Create a notification for the event creator
      if @event.user != current_user  # Ensure creator is not the same as the unregistering user
        Notification.create!(
          recipient: @event.user,  # Event creator
          actor: current_user,     # User unregistering
          action: 'unregistered from your event',
          notifiable: @event
        )
      end
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

  def event_params
    params.require(:event).permit(:event_name, :location, :price, :date, :capacity, :description)
  end

  # def message_params
  #   params.require(:message).permit(:body)
  # end
end
