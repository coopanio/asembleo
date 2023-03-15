# frozen_string_literal: true

class Envelope
  attr_reader :question, :consultation, :token, :values, :created_at

  def initialize(question, token, created_at: Time.now.utc, **kwargs)
    @question = question
    @consultation = question.consultation
    @token = token
    @values = kwargs[:value].is_a?(Array) ? kwargs[:value] : [kwargs[:value]]
    @created_at = created_at
  end

  def votes
    return @votes if defined?(@votes)

    @votes = []
    @values.each do |value|
      @votes.append(
        Vote.new(
          question:,
          value:,
          weight: token.weight,
          event:,
          alias: vote_alias
        )
      )
    end

    @votes
  end

  def receipt
    return @receipt if defined?(@receipt)

    @receipt ||= Receipt.new.tap do |r|
      r.token_id = token.id
      r.question = question
      r.created_at = created_at
      r.fingerprint = FingerprintService.generate(r, token.to_hash, values)
    end
  end

  def save(async: false)
    if async
      VoteCastJob.perform_later(question.id, token.id, values, receipt.created_at)
    else
      votes.map(&:save!)
    end
  end

  private

  def vote_alias
    return unless consultation.ballot == 'open'

    token.on_behalf_of || token.alias || token.to_hash
  end

  def event
    return token.event if token.is_a?(Token)

    consultation.events.first
  end
end
