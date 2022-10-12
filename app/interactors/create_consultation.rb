# frozen_string_literal: true

class CreateConsultation < Actor
  input :title, type: String, allow_nil: false
  input :description, type: String, allow_nil: false

  output :consultation
  output :admin_token
  output :manager_token

  def call
    init_consultation
    init_admin_token
    init_manager_token
    save_models
  end

  private

  def init_consultation
    self.consultation = Consultation.new(title:, description:)
  end

  def init_admin_token
    self.admin_token = Token.new(role: :admin, consultation:)
  end

  def init_manager_token
    return unless consultation.synchronous?

    self.manager_token = Token.new(role: :manager, consultation:, event: default_event)
  end

  def default_event
    return unless consultation.synchronous?
    return @default_event if defined?(@default_event)

    @default_event = Event.new(title: 'Default', consultation:)
  end

  def save_models
    consultation.transaction do
      consultation.save!
      admin_token.save!

      default_event.save! if default_event.present?
      manager_token.save! if manager_token.present?
    end
  end
end
