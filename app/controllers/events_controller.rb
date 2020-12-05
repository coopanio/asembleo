# frozen_string_literal: true

class EventsController < ApplicationController
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

  def create_tokens
    authorize event

    value = create_token_params
    Token.transaction do
      if params[:multiple].present?
        value.each_line do |line|
          create_token(line, flash: false)
        end

        success('Tokens created.')
        redirect_to destination
      else
        create_token(value)

        success('Token created.')
        redirect_back(fallback_location: root_path)
      end
    end
  end

  def update_token
    authorize event

    status = update_token_params
    Token.find(params[:token_id]).update!(status: status)

    if token.enabled?
      success('Token enabled.')
    else
      success('Token disabled.')
    end

    redirect_back(fallback_location: root_path)
  end

  def new_tokens
    authorize event
  end

  def destroy
    authorize event
    event.destroy!

    success('Event deleted.')
    redirect_to controller: 'consultations', action: 'edit', id: consultation.id
  end

  private

  def create_token(identifier, flash: true)
    token = if identifier.blank?
      Token.new(consultation: consultation, event: event)
    else
      identifier = Token.sanitize(identifier)
      Token.find_or_initialize_by(alias: identifier, consultation: consultation, event: event)
    end

    if token.new_record?
      token.save!
      success('Token created.') if flash
    elsif token.disabled?
      token.update!(status: :enabled)
      info("Token enabled again.") if flash
    elsif flash
      info("Token exists and enabled.")
    end
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

  def create_token_params
    params[:value]
  end

  def update_token_params
    params.require(:status)
  end

  alias token current_user
end
