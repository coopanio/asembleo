# frozen_string_literal: true

class EventsController < ApplicationController
  def new
    authorize Event
    @event = Event.new(consultation: consultation)
  end

  def create
    authorize Event
    @event = Event.new(create_params.merge(consultation: consultation))
    token = Token.new(role: :manager, event: @event, consultation: consultation)

    @event.transaction do
      @event.save!
      token.save!
    end

    redirect_to controller: 'consultations', action: 'edit', id: consultation.id
  end

  def edit
    authorize event
  end

  def update
    authorize event
    event.update!(create_params)

    redirect_to controller: 'consultations', action: 'edit', id: consultation.id
  end

  def destroy
    authorize event
    event.destroy!

    redirect_to controller: 'consultations', action: 'edit', id: consultation.id
  end

  private

  def consultation
    current_user.consultation
  end

  def create_params
    params.require(:event).permit(:title)
  end

  def event
    @event ||= policy_scope(Event).find(params[:id])
  end
end
