# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include Pundit
  include Errors

  def current_user
    return unless session[:token]

    @current_user ||= Token.find(session[:token])
  end
end
