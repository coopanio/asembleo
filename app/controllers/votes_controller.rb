# frozen_string_literal: true

class VotesController < ApplicationController
  def create
    authorize Vote
    authorize question, :show?
    validate

    envelope = Envelope.new(question, token, **vote_params.to_h.symbolize_keys)
    envelope.save(async: async?)

    @receipt = envelope.receipt
    @receipt.save!
  end

  private

  def validate
    raise Errors::AlreadyVoted if question.voted?(current_user)

    if params[:vote][:multiple]
      vote_params[:value].each do |value|
        raise Errors::InvalidVoteOption unless question.valid_option?(value)
      end
    else
      raise Errors::InvalidVoteOption unless question.valid_option?(vote_params[:value])
    end
  end

  def vote_params
    params.require(:vote).permit(:question_id, :multiple, :value)
  end

  def question
    @question ||= policy_scope(Question).find(vote_params[:question_id])
  end

  def token
    current_user
  end

  def async?
    Rails.configuration.x.asembleo.async_vote
  end
end
