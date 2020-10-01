# frozen_string_literal: true

class SessionsController < ApplicationController
  include DestinationConcern

  def create
    reset_session
    session[:token] = token.id

    redirect_to destination
  rescue Hashids::InputError, ActiveRecord::RecordNotFound
    raise Errors::AccessDenied
  end

  def destroy
    reset_session
    redirect_to controller: 'main', action: 'index'
  end

  private

  def token
    return @token if defined?(@token)

    @token = Token.from_hash(identifier)
    @token = Token.from_alias(identifier) if @token.nil?

    @token
  end

  def identifier
    params.require(:token)
  end
end
