# frozen_string_literal: true

class ConsultationsController < ApplicationController
  def new
    @consultation = Consultation.new
  end

  def create
    @consultation = Consultation.new(create_params)
    token = Token.new(role: :admin, consultation: @consultation)

    @consultation.transaction do
      @consultation.save!
      token.save!
    end

    redirect_to action: 'show', id: @consultation.id
  end

  def edit
    authorize consultation
  end

  def update
    authorize consultation
    consultation.update!(update_params)

    redirect_to action: 'show', id: @consultation.id
  end

  def show
    authorize consultation
  end

  def destroy
    authorize consultation
    consultation.destroy!

    reset_session
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
