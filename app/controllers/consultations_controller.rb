# frozen_string_literal: true

class ConsultationsController < ApplicationController
  def index
  end

  def new
    if Rails.configuration.x.asembleo.private_instance && current_user.blank?
      redirect_to controller: 'sessions', action: 'new'

      return
    end

    authorize Consultation
    @consultation = Consultation.new
  end

  def create
    authorize Consultation

    result = CreateConsultation.result(create_params)
    raise result.error if result.failure?

    reset_session
    session[:identity_id] = result.admin_token.id

    message = [
      'Consultation created.',
      "Admin token is <strong>#{result.admin_token}</strong>."
    ]
    message << "Manager token is <strong>#{result.manager_token}</strong>." if result.manager_token.present?
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
  end

  def destroy
    authorize consultation
    consultation.destroy!

    reset_session
    success('Consultation deleted.')
    redirect_to controller: 'main', action: 'index'
  end

  private

  def create_params
    params.require(:consultation).permit(:title, :description)
  end

  def update_params
    params.require(:consultation).permit(:title, :description, :status, config: %i[mode ballot])
  end

  def consultation
    @consultation ||= policy_scope(Consultation).find(params[:id])
  end
end
