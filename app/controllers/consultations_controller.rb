# frozen_string_literal: true

class ConsultationsController < ApplicationController
  def new
    @consultation = Consultation.new
  end

  def create
    @consultation = Consultation.new(create_params)
    token = Token.new(role: :admin, consultation: @consultation)
    manager_token = nil

    @consultation.transaction do
      @consultation.save!
      token.save!

      if @consultation.synchronous?
        event = Event.create(title: 'Default', consultation: @consultation)
        manager_token = Token.create(role: :manager, consultation: @consultation, event: event)
      end
    end

    reset_session
    session[:token] = token.id

    message = [
      'Consultation created.',
      "Admin token is <strong>#{token}</strong>."
    ]
    message << "Manager token is <strong>#{manager_token}</strong>." if manager_token.present?
    success(message.join(' '))

    redirect_to action: 'edit', id: @consultation.id
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
    params.require(:consultation).permit(:title, :description, :status)
  end

  def consultation
    @consultation ||= policy_scope(Consultation).find(params[:id])
  end
end
