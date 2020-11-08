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
    return @active_question if defined?(@active_question)

    receipts = Receipt.arel_table
    questions = EventsQuestion.arel_table

    join_condition = [
      receipts[:question_id].eq(questions[:question_id]),
      receipts[:token_id].eq(token.id)
    ]
    where = {
      status: :opened,
      receipts: { id: nil },
      consultation: token.consultation.id
    }

    join = questions.join(receipts, Arel::Nodes::OuterJoin).on(*join_condition)
    query = EventsQuestion.joins(join.join_sources).where(**where).order(:id)

    @active_question = query.first.try(:question)
  end

  def consultation
    @consultation ||= token.consultation
  end
end
