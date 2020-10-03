# frozen_string_literal: true

module EventsHelper
  def question_opener_closer_link(event, question)
    return '-' unless question.consultation.opened?

    rel = EventsQuestion.find_by(event: event, question: question)
    if rel.nil? || rel.closed?
      return button_to('Obrir', question_action_params('open', event, question), **button_params)
    end

    button_to('Tancar', question_action_params('close', event, question), **button_params)
  end

  def token_enabler_disabler_link(token)
    return '-' if token.event.consultation.closed?
    return '-' if token == @current_user

    if token.enabled?
      button_to('Desactivar', update_token_action_params(token, :disabled), **button_params)
    else
      button_to('Activar', update_token_action_params(token, :enabled), **button_params)
    end
  end

  private

  def question_action_params(action, event, question)
    {
      controller: 'questions',
      action: action,
      id: question.id,
      event: {
        id: event.id
      }
    }
  end

  def update_token_action_params(token, status)
    {
      controller: 'events',
      action: 'update_token',
      id: token.event.id,
      token_id: token.id,
      status: status
    }
  end

  def button_params
    {
      method: :patch,
      class: 'btn btn-link py-0'
    }
  end
end
