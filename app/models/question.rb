# frozen_string_literal: true

class Question < ApplicationRecord
  has_paper_trail

  belongs_to :consultation
  has_many :receipts, dependent: :destroy
  has_many :votes, dependent: :destroy

  enum status: { draft: 0, open: 1, closed: 2 }

  def self.next(token)
    receipts = Receipt.arel_table
    questions = Question.arel_table
    condition = [receipts[:question_id].eq(questions[:id]), receipts[:token_id].eq(token.id)]
    join = questions.join(receipts, Arel::Nodes::OuterJoin).on(*condition)
    joins(join.join_sources).where(status: :open, receipts: { id: nil }).order(:weight).first
  end

  def valid_option?(value)
    options[value].present?
  end

  def voted?(token)
    receipts.exists?(token: token)
  end
end
