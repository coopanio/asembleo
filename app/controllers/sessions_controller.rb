# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    raise Errors::AccessDenied if token.disabled?

    reset_session
    session[:token] = token.id

    redirect_to destination
  rescue ActiveRecord::RecordNotFound
    raise Errors::AccessDenied
  end

  def destroy
    reset_session
    redirect_to root_path
  end

  private

  def token
    return @token if defined?(@token)

    @token = Rails.cache.fetch("tokens/#{identifier}") do
      Token.from_value(identifier)
    end
  end

  def identifier
    params.require(:token)
  end
end
