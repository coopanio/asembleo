# frozen_string_literal: true

module EventsHelper
  def question_opener_closer_link(event, question)
    return '-' unless question.opened?
    return '-' unless question.consultation.opened?

    rel = EventsQuestion.find_by(event: event, question: question)
    if rel.nil? || rel.closed?
      return button_to('Obrir', question_action_params('open', event, question), **button_params)
    end

    button_to('Tancar', question_action_params('close', event, question), **button_params)
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

  def button_params
    {
      method: :patch,
      class: 'btn btn-link py-0'
    }
  end
end
