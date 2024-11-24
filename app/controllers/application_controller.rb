# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_raven_context
  before_action :reject_head_requests
  before_action :check_token, unless: -> {
    return true if controller_name == 'consultations' && action_name == 'create'
    return true if controller_name == 'main' && action_name == 'index'
    return true if controller_name == 'sessions' && action_name.in?(%w[create create_from_email new])
  }
  before_action :set_context

  include Errors
  include FlashConcern
  include Pundit::Authorization

  def reject_head_requests
    raise ActionController::BadRequest if request.head?
  end

  def set_raven_context
    Sentry.set_user(id: current_user.try(:id))
    Sentry.set_extras(params: params.to_unsafe_h, url: request.url)
  end

  def check_token
    if current_user.blank?
      error(I18n.t('sessions.not_valid'))
      redirect_to root_path
      return
    end

    return unless current_user.disabled?

    error(I18n.t('events.token_disabled'))

    reset_session
    redirect_to root_path
  end

  def current_user
    return if session[:identity_id].blank?
    return @current_user if defined?(@current_user)

    resource_class = session[:identity_type].constantize
    @current_user ||= resource_class.find(session[:identity_id])
  end

  def set_context
    Context.reset

    Context.identity = @current_user

    Context.consultation_id = self.consultation_id if respond_to?(:consultation_id, true)
    Context.consultation_id = self.consultation&.id if respond_to?(:consultation, true)

    Context.event_id = self.event_id if respond_to?(:event_id, true)
    Context.event_id = self.event&.id if respond_to?(:event, true)
  end

  def pundit_user
    Context.context
  end
end
