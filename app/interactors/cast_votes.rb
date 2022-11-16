# frozen_string_literal: true

class CastVotes < Actor
  input :current_user, type: Token, allow_nil: false
  input :votes_params, allow_nil: false

  output :receipts

  # TODO copy question config
  # TODO allow to vote multiple times the main option
  def call
    self.receipts = []

    votes_params.each do |vote_params|
      validate(vote_params)
    end

    votes_params.each do |vote_params|
      cast(vote_params)
    end
  end

  private

  def validate(vote_params)
    question = vote_params[:question]
    values = vote_params[:value]

    raise Errors::AlreadyVoted if question.voted?(current_user)
    raise Errors::TooManyOptions, question.max_options if values.size > question.max_options

    values.each do |value|
      raise Errors::InvalidVoteOption unless question.valid_option?(value)
    end
  end

  def cast(vote_params)
    question = vote_params[:question]

    envelope = Envelope.new(question, current_user, **vote_params.to_h.symbolize_keys)
    envelope.save(async: async?)

    envelope.receipt.save!
    self.receipts << envelope.receipt
  end

  def async?
    Rails.configuration.x.asembleo.async_vote
  end
end
