# frozen_string_literal: true

class ConsultationsController < ApplicationController
  def new
    @consultation = Consultation.new
  end

  def create
    result = CreateConsultation.call(create_params)
    raise result.error unless result.success?

    reset_session
    session[:token] = result.admin_token.id

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
    params.require(:consultation).permit(:title, :description, :status, config: [:mode, :ballot])
  end

  def consultation
    @consultation ||= policy_scope(Consultation).find(params[:id])
  end
end
