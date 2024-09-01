# frozen_string_literal: true

class CreateConsultation < Actor
  input :title, type: String, allow_nil: false
  input :description, type: String, allow_nil: false
  input :admin_email_address, type: String, allow_nil: true, default: nil

  output :consultation
  output :tokens
  output :admin_token

  def call
    init_consultation
    init_tokens
    save_models
    deliver_tokens if admin_email_address.present?
  end

  private

  def init_consultation
    self.consultation = Consultation.new(title:, description:)
  end

  def init_tokens
    self.admin_token = Token.new(role: :admin, consultation:)
    self.tokens = [admin_token]

    self.tokens << Token.new(role: :manager, consultation:, event: default_event)
  end

  def default_event
    return @default_event if defined?(@default_event)

    @default_event = Event.new(title: I18n.t('interactors.create_consultation.default'), consultation:)
  end

  def save_models
    consultation.transaction do
      consultation.save!
      tokens.each(&:save!)

      default_event.save! if default_event.present?
    end
  end

  def deliver_tokens
    ConsultationsMailer.default_tokens_email(admin_email_address, self.tokens).deliver_later
  end
end
