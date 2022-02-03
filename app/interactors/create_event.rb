# frozen_string_literal: true

class CreateEvent
  include Interactor

  def call
    init_event
    init_manager_token
    save_models
  end

  private

  def init_event
    context.event = Event.new(context.to_h)
  end

  def init_manager_token
    context.manager_token = Token.new(role: :manager, event: context.event, consultation: context.consultation)
  end
  
  def save_models
    context.event.transaction do
      context.event.save!
      context.manager_token.save!
    end
  end
end
