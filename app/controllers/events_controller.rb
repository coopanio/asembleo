# frozen_string_literal: true

class EventsController < ApplicationController
  include DestinationConcern

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

    redirect_back(fallback_location: root_path)
  end

  def edit
    authorize event

    @consultation = event.consultation
  end

  def update
    authorize event
    event.update!(update_params)

    redirect_back(fallback_location: root_path)
  end

  def next_question
    authorize event
    redirect_to destination
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

    redirect_to controller: 'consultations', action: 'edit', id: event.consultation.id
  end

  private

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

  alias token current_user
end
