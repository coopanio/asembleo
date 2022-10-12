# frozen_string_literal: true

class CreateEvent < Actor
  input :title, type: String, allow_nil: false
  input :consultation, type: Consultation, allow_nil: false

  output :event

  def call
    self.event = Event.new(title:, consultation:)
    @manager_token = Token.new(role: :manager, event:, consultation:)

    event.transaction do
      event.save!
      @manager_token.save!
    end
  end
end
