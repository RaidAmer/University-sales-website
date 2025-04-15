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
end
