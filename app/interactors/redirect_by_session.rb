# frozen_string_literal: true

class RedirectBySession < Actor
  include Rails.application.routes.url_helpers

  input :consultation_id, type: Integer, allow_nil: true, default: -> { nil }
  input :event_id, type: Integer, allow_nil: true, default: -> { nil }
  input :identity, type: [Token, User], allow_nil: false

  output :destination, type: String

  def call
    self.destination = find_destination
  end

  private

  def find_destination
    return consultations_url(only_path: true) if consultation_id.nil? && identity.is_a?(User)
    return edit_consultation_url(consultation_id, only_path: true) if identity.admin?
    return edit_event_url(event_id, only_path: true) if identity.manager?
    return consultation_url(consultation_id, only_path: true) if active_question.blank?

    consultation_question_url(consultation_id, active_question, only_path: true)
  end

  def active_question
    return @active_question if defined?(@active_question)

    receipts = Receipt.arel_table
    questions = EventsQuestion.arel_table

    join_condition = [
      receipts[:question_id].eq(questions[:question_id]),
      receipts[:token_id].eq(identity.id)
    ]
    where = {
      status: :opened,
      receipts: { id: nil },
      consultation: consultation_id
    }

    join = questions.join(receipts, Arel::Nodes::OuterJoin).on(*join_condition)
    query = EventsQuestion.joins(join.join_sources).where(**where).order(:id)

    @active_question = query.pick(:question_id)
  end
end
