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

    redirect
  end

  def edit
    authorize event
  end

  def update
    authorize event
    event.update!(update_params)

    redirect
  end

  def generate_tokens
    authorize event
    
    @tokens = []
    total = generate_tokens_params.to_i

    Token.transaction do
      total.times do
        @tokens << Token.create(consultation: event.consultation, event: event)
      end
    end
  end

  def destroy
    authorize event
    event.destroy!

    redirect
  end

  private

  def redirect
    if current_user.admin?
      redirect_to controller: 'consultations', action: 'edit', id: consultation.id
    else
      redirect_to controller: 'events', action: 'edit', id: event.id
    end
  end

  def consultation
    current_user.consultation
  end

  def event
    @event ||= policy_scope(Event).find(params[:id])
  end

  def create_params
    params.require(:event).permit(:title)
  end

  def update_params
    if current_user.admin?
      params.require(:event).permit(:title, :status)
    else
      params.require(:event).permit(:status)
    end
  end

  def generate_tokens_params
    params.require(:total)
  end
end
