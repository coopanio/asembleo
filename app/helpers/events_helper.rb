# frozen_string_literal: true

module EventsHelper
  def question_opener_closer_link(event, question)
    return '-' unless question.consultation.opened?

    rel = EventsQuestion.find_by(event:, question:)
    if rel.nil? || rel.closed?
      return button_to(I18n.t('helpers.events_helper.open'), question_action_params('open', event, question), **button_params)
    end

    button_to(I18n.t('helpers.events_helper.close'), question_action_params('close', event, question), **button_params)
  end

  def all_events_question_opener_closer_link(question)
    return '-' unless question.consultation.opened?

    rels = EventsQuestion.where(question:)
    return button_to(I18n.t('helpers.events_helper.open'), question_action_params('open_all', nil, question), **button_params) if rels.all?(&:closed?)

    button_to(I18n.t('helpers.events_helper.close'), question_action_params('close_all', nil, question), **button_params)
  end

  def token_enabler_disabler_link(token)
    return '-' if token.event.consultation.closed?
    return '-' if token == @current_user

    if token.enabled?
      button_to(I18n.t('helpers.events_helper.disable'), update_token_action_params(token, :disabled), **button_params)
    else
      button_to(I18n.t('helpers.events_helper.enable'), update_token_action_params(token, :enabled), **button_params)
    end
  end

  private

  def question_action_params(action, event, question)
    params = {
      controller: 'questions',
      action:,
      consultation_id: question.consultation_id,
      id: question.id
    }

    return params if event.nil?

    params[:event] = {
      id: event.id
    }

    params
  end

  def update_token_action_params(token, status)
    {
      controller: 'events',
      action: 'update_token',
      id: token.event.id,
      token_id: token.id,
      status:
    }
  end

  def button_params
    {
      method: :patch,
      class: 'btn btn-link py-0'
    }
  end
end
