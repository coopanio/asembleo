# frozen_string_literal: true

require 'csv'

class EventsController < ApplicationController
  def new
    authorize Event
    @event = Event.new(consultation: current_user.consultation)
  end

  def create
    authorize Event

    result = CreateEvent.result(create_params.merge(consultation: current_user.consultation).to_h.symbolize_keys)
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

    Token.transaction do
      if multiple
        lines = if params[:value].present?
          params[:value].open
        elsif params[:value_raw].present?
          params[:value_raw]
        else
          error(I18n.t('events.no_identifiers'))
          redirect_back(fallback_location: root_path)
          return
        end
        identifiers = CSV.new(lines).read.map(&:first)

        result = BulkCreateTokens.result(identifiers:, role:, aliased:, send_magic_link:, event:)
        raise result.error if result.failure?

        success(I18n.t('events.tokens_created_or_enabled'))

        result = RedirectBySession.call(Context.to_h)
        redirect_to result.destination
      else
        identifier = params[:value].presence

        send_magic_link = false
        send_magic_link = EmailValidator.valid?(identifier, mode: :strict) if consultation.config.distribution == 'email'

        result = CreateToken.result(identifier:, role:, aliased:, send_magic_link:, event:)

        if result.skip
          error(I18n.t("events.#{result.skip_reason}"))
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

  def deactivate_tokens
    authorize event

    Token.transaction do
      event.tokens.where(role: :voter).update_all(status: :disabled)

      success(I18n.t('events.tokens_disabled'))
    end

    redirect_back(fallback_location: root_path)
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
    params.permit(:value, :multiple, :send, :role)
  end

  def role
    create_token_params.fetch(:role, :voter).to_sym
  end

  def multiple
    create_token_params.fetch(:multiple, 'false') == 'true'
  end

  def aliased
    consultation.config.alias != 'none'
  end

  def send_magic_link
    create_token_params.fetch(:send, '0').to_i == 1
  end

  def update_token_params
    params.require(:status)
  end

  def consultation
    return nil if event.nil?

    @consultation ||= event.consultation
  end
end
