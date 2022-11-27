# frozen_string_literal: true

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

    result = RedirectBySession.call(identity: current_user)
    redirect_to result.destination
  end

  def create_tokens
    authorize event

    params = create_token_params
    role = params.fetch(:role, :voter).to_sym

    Token.transaction do
      if params[:multiple].present?
        lines = params[:value].open
        lines.each_line do |line|
          CreateToken.call(
            identifier: line,
            role:,
            aliased: params.fetch(:aliased, '0').to_i == 1,
            send_magic_link: params.fetch(:send, '0').to_i == 1,
            event:
          )
        end

        success('Tokens created or enabled.')

        result = RedirectBySession.call(identity: current_user)
        redirect_to result.destination
      else
        result = CreateToken.result(
          identifier: params[:value].presence,
          role:,
          aliased: params.fetch(:aliased, '0').to_i == 1,
          send_magic_link: params.fetch(:send, '0').to_i == 1,
          event:
        )

        if result.skip
          success('Token already issued.')
        elsif result.token.new_record?
          success('Token created.')
        elsif result.token.disabled?
          info('Token enabled again.')
        else
          info('Token exists and enabled.')
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

    consultation = event.consultation
    event.destroy!

    success('Event deleted.')
    redirect_to controller: 'consultations', action: 'edit', id: consultation.id
  end

  private

  def event
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
    @consultation ||= event.consultation
  end
end
