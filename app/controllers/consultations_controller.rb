# frozen_string_literal: true

class ConsultationsController < ApplicationController
  def index
    authorize Consultation

    @consultations = Consultation.all.order(created_at: :desc)
  end

  def new
    authorize Consultation
    @consultation = Consultation.new
  end

  def create
    authorize Consultation

    result = CreateConsultation.result(create_params.merge(admin_email_address: current_user&.email).to_h.symbolize_keys)
    raise result.error if result.failure?

    reset_session
    session[:identity_id] = result.admin_token.id
    session[:identity_type] = result.admin_token.class.name

    message = [
      I18n.t('consultations.consultation_created')
    ]

    result.tokens.each do |token|
      next if token.blank?

      message << I18n.t('consultations.consultation_token_created', token:, role: token.translated_role.titleize)
    end

    success(message.join(' '))

    @consultation = result.consultation
    redirect_to action: 'edit', id: result.consultation.id
  end

  def edit
    authorize consultation

    @event = consultation.events.first if consultation.synchronous?
  end

  def update
    authorize consultation
    consultation.update!(update_params)

    redirect_back(fallback_location: root_path)
  end

  def show
    authorize consultation

    return redirect_to controller: 'consultations', action: 'edit', id: consultation.id if current_user.admin?
  end

  def destroy
    authorize consultation
    consultation.destroy!

    reset_session
    success(I18n.t('consultations.consultation_deleted'))
    redirect_to controller: 'main', action: 'index'
  end

  private

  def create_params
    params.require(:consultation).permit(:title, :description, config: %i[mode ballot distribution alias])
  end

  def update_params
    params.require(:consultation).permit(
      :title,
      :description,
      :status,
      config: %i[mode ballot distribution alias],
      notification: %i[subject body]
    )
  end

  def event
    return @event if defined?(@event)
    return @event = current_user.event if current_user.respond_to?(:event)
    return @event = nil if consultation.nil?

    @event = consultation.events.first
  end

  def consultation
    return nil if params[:id].blank?

    @consultation ||= Consultation.find(params[:id])
  end
end
