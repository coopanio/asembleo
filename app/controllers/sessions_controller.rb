# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    result = AuthenticateCredentials.result(identifier:, password:)
    raise result.error if result.failure?

    reset_session
    session[:identity_id] = result.identity.id
    session[:identity_type] = result.identity.class.name

    result = RedirectBySession.call(identity: result.identity)
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

  def create_params
    params.require(:session).permit(:identifier, :password)
  end
end
