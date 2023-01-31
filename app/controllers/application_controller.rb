# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_raven_context
  before_action :check_token
  before_action :set_locale

  include Errors
  include FlashConcern
  include Pundit::Authorization

  def set_raven_context
    Sentry.set_user(id: current_user.try(:id))
    Sentry.set_extras(params: params.to_unsafe_h, url: request.url)
  end

  def check_token
    return if current_user.blank?
    return unless current_user.disabled?

    error(I18n.t("events.token_disabled"))

    reset_session
    redirect_to root_path
  end

  def current_user
    return if session[:identity_id].blank?
    return @current_user if defined?(@current_user)

    resource_class = session[:identity_type].constantize
    @current_user ||= resource_class.find(session[:identity_id])
  end

  def pundit_user
    return unless current_user.present?
    return current_user if current_user.respond_to?(:consultation_id)

    OpenStruct.new(consultation_id: consultation&.id, admin?: current_user.admin?)
  end
end
