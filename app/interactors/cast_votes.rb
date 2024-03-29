# frozen_string_literal: true

class CastVotes < Actor
  input :current_user, type: [Token, User], allow_nil: false
  input :votes_params, allow_nil: false

  output :receipts

  # TODO: allow to vote multiple times the main option
  def call
    self.receipts = []

    validate
    cast
  end

  private

  def validate
    validate_votes
    validate_group_main_option
  end

  def validate_votes
    votes_params.each do |vote_params|
      validate_vote(vote_params)
    end
  end

  def validate_vote(vote_params)
    question = vote_params[:question]
    values = vote_params[:value]

    raise Errors::AlreadyVoted.new(consultation: question.consultation) if question.voted?(current_user)
    raise Errors::TooManyOptions, question.max_options if values.size > question.max_options

    values.each do |value|
      raise Errors::InvalidVoteOption unless question.valid_option?(value)
    end
  end

  def validate_group_main_option
    question = votes_params.first[:question]
    group = question.group
    return if question.group.blank?

    main_option = question.options.detect { |option| option.main }
    return if main_option.blank?

    main_value = main_option.value
    limit = group.config.limit_for(main_value)
    values = votes_params.map { |vote_params| vote_params[:value] }.flatten.tally

    raise Errors::TooManyMainOptions.new(main_option, limit) if values[main_value] > limit
  end

  def cast
    votes_params.each do |vote_params|
      cast_vote(vote_params)
    end
  end

  def cast_vote(vote_params)
    question = vote_params[:question]

    envelope = Envelope.new(question, current_user, **vote_params.to_h.symbolize_keys)
    envelope.save_later

    envelope.receipt.save!
    self.receipts << envelope.receipt
  end
end
