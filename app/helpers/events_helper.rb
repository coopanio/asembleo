# frozen_string_literal: true

module EventsHelper
  def question_opener_closer_link(event, question)
    return '-' unless question.opened?
    return '-' unless question.consultation.opened?

    rel = EventsQuestion.find_by(event: event, question: question)
    return button_to('Obrir', { controller: 'questions', action: 'open', id: question.id, event: { id: event.id } }, method: :patch, class: 'btn btn-link py-0') if rel.nil? || rel.closed?

    button_to('Tancar', { controller: 'questions', action: 'close', id: question.id, event: { id: event.id } }, method: :patch, class: 'btn btn-link py-0')
  end
end
