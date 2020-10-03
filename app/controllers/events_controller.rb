# frozen_string_literal: true

class EventsController < ApplicationController
  include DestinationConcern, FlashConcern

  def new
    authorize Event
    @event = Event.new(consultation: consultation)
  end

  def create
    authorize Event
    @event = Event.new(create_params.merge(consultation: consultation))
    token = Token.new(role: :manager, event: event, consultation: consultation)

    @event.transaction do
      @event.save!
      token.save!
    end

    redirect_to action: 'edit', id: event.id
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

  def create_token
    authorize event

    identifier = create_token_params
    begin
      Token.create!(alias: identifier, consultation: consultation, event: event)
    rescue ActiveRecord::RecordInvalid
      error('No es pot crear un identificador duplicat.')
    else
      success('Identificador creat.')
    end

    redirect_back(fallback_location: root_path)
  end

  def update_token
    authorize event

    status = update_token_params
    Token.find(params[:token_id]).update!(status: status)

    if token.enabled?
      success('Identificador activat.')
    else
      success('Identificador desactivat.')
    end
    redirect_back(fallback_location: root_path)
  end

  def destroy
    authorize event
    event.destroy!

    success('Trobada eliminada.')
    redirect_to controller: 'consultations', action: 'edit', id: consultation.id
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

  def create_token_params
    params.require(:alias)
  end

  def update_token_params
    params.require(:status)
  end

  alias token current_user
end
