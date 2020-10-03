# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_raven_context
  before_action :check_token

  include DestinationConcern
  include Errors
  include FlashConcern
  include Pundit

  def set_raven_context
    Raven.user_context(id: current_user.try(:id))
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def check_token
    return unless current_user.present?

    if current_user.disabled?
      error('Identificador desactivat.')

      reset_session
      redirect_to root_path
    end
  end

  def current_user
    return unless session[:token]

    @current_user ||= Token.find(session[:token])
  end
end
