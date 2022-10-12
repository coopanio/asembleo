# frozen_string_literal: true

class RedirectBySession < Actor
  include Rails.application.routes.url_helpers

  input :identity, type: [Token], allow_nil: false

  output :destination

  def call
    self.destination = find_destination
  end

  private

  def find_destination
    return edit_consultation_url(identity.consultation_id, only_path: true) if identity.admin?
    return edit_event_url(identity.event_id, only_path: true) if identity.manager?
    return consultation_url(identity.consultation_id, only_path: true) if active_question.blank?

    question_url(active_question, only_path: true)
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
      consultation: identity.consultation_id
    }

    join = questions.join(receipts, Arel::Nodes::OuterJoin).on(*join_condition)
    query = EventsQuestion.joins(join.join_sources).where(**where).order(:id)

    @active_question = query.pick(:question_id)
  end
end
