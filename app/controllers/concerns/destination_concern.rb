# frozen_string_literal: true

module DestinationConcern
  include ActiveSupport::Concern

  private

  def destination
    if token.admin?
      edit_consultation_url(consultation)
    elsif token.manager?
      edit_event_url(token.event)
    elsif active_question.blank?
      consultation_url(consultation)
    else
      question_url(active_question)
    end
  end

  def active_question
    @active_question ||= Question.next(token)
  end

  def consultation
    @consultation ||= token.consultation
  end
end