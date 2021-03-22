# frozen_string_literal: true

class VoteCastJob < ApplicationJob
  queue_as :default

  # TODO: Vote hash chaining
  def perform(question_id, token_id, value, created_at)
    question = Question.find(question_id)
    token = Token.find(token_id)

    envelope = Envelope.new(question, token, value: value, created_at: created_at)
    envelope.save
  end
end
