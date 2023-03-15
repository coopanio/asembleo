# frozen_string_literal: true

class MainController < ApplicationController
  def index
    return if current_user.blank?

    result = RedirectBySession.call(Context.to_h)
    redirect_to result.destination
  end
end
