# frozen_string_literal: true

class VotesController < ApplicationController
  def create
    authorize Vote

    if params.to_unsafe_h.fetch(:vote, {}).length != questions.length
      error('Please cast a vote for each question')
      redirect_back fallback_location: root_path

      return
    end

    raise ActiveRecord::RecordNotFound if questions.empty?

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
    @questions ||= policy_scope(Question).where(id: question_ids)
  end

  def question_ids
    return group.questions.map(&:id) if group.present?

    params.require(:question_id).to_i
  end

  def group
    return nil if params.fetch(:group_id, nil).blank?

    @group ||= QuestionGroup.find(params[:group_id])
  end
end
