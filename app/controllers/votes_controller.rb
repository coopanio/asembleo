# frozen_string_literal: true

class VotesController < ApplicationController
  def create
    authorize Vote

    questions.each do |question|
      authorize question, :show?
    end

    result = CastVotes.result(votes_params:, current_user:)
    raise result.error if result.failure?

    @receipt = result.receipts.last
  end

  private

  def votes_params
    vps = []

    questions.each do |question|
      vp = params.require(:vote).require(question.id.to_s).permit(value: []).to_h
      vps << vp.merge(question: question)
    end

    vps
  end

  def questions
    @questions ||= policy_scope(Question).find(question_ids)
  end

  def question_ids
    params.require(:vote).keys.map(&:to_i)
  end
end
