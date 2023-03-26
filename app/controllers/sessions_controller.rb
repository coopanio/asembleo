# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
    return if Rails.configuration.x.asembleo.private_instance

    redirect_to controller: 'main', action: 'index'
  end

  def create_from_email # for open registration login
    result = CreateMagicLink.result(email: identifier, send_email: true)
    raise result.error if result.failure?

    info(t('sessions.magic_link_sent'))

    redirect_to root_path
  end

  def create
    result = AuthenticateCredentials.result(identifier:, password:)
    raise result.error if result.failure?

    reset_session
    session[:identity_id] = result.identity.id
    session[:identity_type] = result.identity.class.name

    consultation_id = nil
    consultation_id = result.identity.consultation_id if result.identity.is_a?(Token)

    event_id = nil
    event_id = result.identity.event_id if result.identity.is_a?(Token)

    result = RedirectBySession.call(identity: result.identity, consultation_id:, event_id:)
    redirect_to result.destination
  end

  def destroy
    reset_session
    redirect_to root_path
  end

  private

  def identifier
    return params[:token] if request.get?

    params.dig(:session, :identifier)
  end

  def password
    params.dig(:session, :password)
  end
end
