# frozen_string_literal: true

class MainController < ApplicationController
  def index
    return if current_user.blank?

    redirect_to destination
    nil
  end

  alias token current_user
end
