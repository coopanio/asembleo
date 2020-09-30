# frozen_string_literal: true

module EventsHelper
  def question_opener_closer_link(event, question)
    return '-' unless question.opened?
    return '-' unless question.consultation.opened?

    rel = EventsQuestion.find_by(event: event, question: question)
    return link_to('Obrir', controller: 'questions', action: 'open', method: :patch, id: question.id) if rel.nil? || rel.closed?

    link_to('Tancar', controller: 'questions', action: 'close', method: :patch, id: question.id)
  end
end
