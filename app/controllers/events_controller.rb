# frozen_string_literal: true

require 'csv'

class EventsController < ApplicationController
  def new
    authorize Event
    @event = Event.new(consultation: current_user.consultation)
  end

  def create
    authorize Event

    result = CreateEvent.result(create_params.merge(consultation: current_user.consultation))
    raise result.error if result.failure?

    redirect_to action: 'edit', id: result.event.id
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

    result = RedirectBySession.call(Context.to_h)
    redirect_to result.destination
  end

  def create_tokens
    authorize event

    params = create_token_params
    role = params.fetch(:role, :voter).to_sym
    multiple = params.fetch(:multiple, 'false') == 'true'

    Token.transaction do
      if multiple
        lines = params[:value].open
        CSV.new(lines).read.each do |line|
          CreateToken.call(
            identifier: line.first,
            role:,
            aliased: params.fetch(:aliased, '0').to_i == 1,
            send_magic_link: params.fetch(:send, '0').to_i == 1,
            event:
          )
        end

        success(I18n.t('events.tokens_created_or_enabled'))

        result = RedirectBySession.call(Context.to_h)
        redirect_to result.destination
      else
        identifier = params[:value].presence
        send_magic_link = params.fetch(:send, '0').to_i == 1
        send_magic_link ||= EmailValidator.valid?(identifier, mode: :strict) if consultation.config.distribution == 'email'

        result = CreateToken.result(
          identifier:,
          role:,
          aliased: params.fetch(:aliased, '0').to_i == 1,
          send_magic_link:,
          event:
        )

        if result.skip
          success(I18n.t('events.token_already_issued'))
        elsif result.token.new_record?
          success(I18n.t('events.token_created'))
        elsif result.token.disabled?
          info(I18n.t('events.token_enabled_again'))
        else
          info(I18n.t('events.token_exists_and_enabled'))
        end

        redirect_back(fallback_location: root_path)
      end
    end
  end

  def update_token
    authorize event

    status = update_token_params
    token = Token.find(params[:token_id])
    token.update!(status:)

    if token.enabled?
      success(I18n.t('events.token_enabled'))
    else
      success(I18n.t('events.token_disabled'))
    end

    redirect_back(fallback_location: root_path)
  end

  def new_tokens
    authorize event
  end

  def destroy
    authorize event

    consultation = event.consultation
    event.destroy!

    success(I18n.t('events.event_deleted'))
    redirect_to controller: 'consultations', action: 'edit', id: consultation.id
  end

  private

  def event
    return nil if params[:id].blank?

    @event ||= Event.find(params.require(:id))
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
    params.permit(:value, :aliased, :multiple, :send, :role)
  end

  def update_token_params
    params.require(:status)
  end

  def consultation
    return nil if event.nil?

    @consultation ||= event.consultation
  end
end
