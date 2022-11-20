# frozen_string_literal: true

class CastVotes < Actor
  input :current_user, type: Token, allow_nil: false
  input :votes_params, allow_nil: false

  output :receipts

  # TODO allow to vote multiple times the main option
  def call
    self.receipts = []

    validate
    cast
  end

  private

  def validate
    validate_votes
    validate_main_option
  end

  def validate_votes
    votes_params.each do |vote_params|
      validate_vote(vote_params)
    end
  end

  def validate_vote(vote_params)
    question = vote_params[:question]
    values = vote_params[:value]

    raise Errors::AlreadyVoted if question.voted?(current_user)
    raise Errors::TooManyOptions, question.max_options if values.size > question.max_options

    values.each do |value|
      raise Errors::InvalidVoteOption unless question.valid_option?(value)
    end
  end

  def validate_main_option
    question = votes_params.first[:question]
    main_option = question.options.detect { |option| option.main }

    return if main_option.blank?

    values = votes_params.map { |vote_params| vote_params[:value] }.flatten.tally
    raise Errors::TooManyMainOptions, main_option if values[main_option.value] > 1
  end

  def cast
    votes_params.each do |vote_params|
      cast_vote(vote_params)
    end
  end

  def cast_vote(vote_params)
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
