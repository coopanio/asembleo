# frozen_string_literal: true

class CreateConsultation
  include Interactor

  def call
    init_consultation
    init_default_event
    init_admin_token
    init_manager_token
    save_models
  end

  private

  def init_consultation
    context.consultation = Consultation.new(context.to_h)
  end

  def init_admin_token
    context.admin_token = Token.new(role: :admin, consultation: context.consultation)
  end

  def init_manager_token
    return unless context.consultation.synchronous?

    context.manager_token = Token.new(role: :manager, consultation: context.consultation, event: context.default_event)
  end

  def init_default_event
    return unless context.consultation.synchronous?

    context.default_event = Event.new(title: 'Default', consultation: context.consultation)
  end

  def save_models
    context.consultation.transaction do
      context.consultation.save!
      context.admin_token.save!
      context.default_event.save! if context.default_event.present?
      context.manager_token.save! if context.manager_token.present?
    end
  end
end
