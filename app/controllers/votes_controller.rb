# frozen_string_literal: true

class VotesController < ApplicationController
  def create
    authorize Vote
    authorize question, :show?
    validate

    @receipt = receipt
    @receipt.save!

    # TODO: sidekiq worker to store votes with chained hash
    vote = Vote.new(question: question, value: vote_params[:value], weight: token.weight)
    vote.save!
  end

  private

  def validate
    raise Errors::InvalidVoteOption unless question.valid_option?(vote_params[:value])
    raise Errors::AlreadyVoted if question.voted?(current_user)
  end

  def vote_params
    params.require(:vote).permit(:question_id, :value)
  end

  def question
    @question ||= policy_scope(Question).find(vote_params[:question_id])
  end

  def receipt
    return @receipt if defined?(@receipt)

    @receipt ||= Receipt.new.tap do |r|
      r.token = token
      r.question = question
      r.created_at = Time.now.utc
      r.fingerprint = FingerprintService.generate(r, current_user.to_hash, vote_params[:value])
    end
  end

  def token
    current_user
  end
end
