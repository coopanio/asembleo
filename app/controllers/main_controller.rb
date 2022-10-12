# frozen_string_literal: true

class MainController < ApplicationController
  def index
    return if current_user.blank?

    result = RedirectBySession.call(identity: current_user)
    redirect_to result.destination
  end
end
