# frozen_string_literal: true

class VoteCastJob < ApplicationJob
  queue_as :default

  # TODO: Vote hash chaining
  def perform(question_id, token_class, token_id, value, created_at)
    question = Question.find(question_id)

    token_class = token_class.constantize
    token = token_class.find(token_id)

    envelope = Envelope.new(question, token, value:, created_at:)
    envelope.save
  end
end
