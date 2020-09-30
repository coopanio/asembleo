# frozen_string_literal: true

class Question < ApplicationRecord
  has_paper_trail

  belongs_to :consultation
  has_many :receipts, dependent: :destroy
  has_many :votes, dependent: :destroy

  enum status: { draft: 0, opened: 1, closed: 2 }

  def self.next(token)
    receipts = Receipt.arel_table
    questions = EventsQuestion.arel_table
    condition = [receipts[:question_id].eq(questions[:question_id]), receipts[:token_id].eq(token.id)]
    join = questions.join(receipts, Arel::Nodes::OuterJoin).on(*condition)
    query = EventsQuestion.joins(join.join_sources).where(status: :opened, receipts: { id: nil }).order(:weight)
    query.first.try(:question)
  end

  def valid_option?(value)
    options[value].present?
  end

  def voted?(token)
    receipts.exists?(token: token)
  end
end
