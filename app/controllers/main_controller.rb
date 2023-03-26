# frozen_string_literal: true

class MainController < ApplicationController
  def index
    @login_path = login_path
    return if current_user.blank?

    result = RedirectBySession.call(Context.to_h)
    redirect_to result.destination
  end

  def login_path
    return magic_login_path if Rails.configuration.x.asembleo.open_registration

    sessions_path
  end
end
